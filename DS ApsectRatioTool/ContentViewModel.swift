//
//  ContentViewModel.swift
//  DS Aspect Ratio Tool
//
//  Created by Codex on 3/19/26.
//

import Combine
import Foundation

enum StatusKind {
    case info
    case success
    case error
}

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var editedWidth: Int = 0
    @Published var editedHeight: Int = 0
    @Published private(set) var selectedPreset: ResolutionPreset = .custom
    @Published private(set) var currentFileURL: URL?
    @Published private(set) var statusMessage: String = "Looking for the default Setting.cfg file..."
    @Published private(set) var statusKind: StatusKind = .info
    @Published private(set) var isFileSaved: Bool = false

    private let service: ConfigFileService
    private var isUpdatingFields = false

    init(service: ConfigFileService = ConfigFileService()) {
        self.service = service
    }

    var isFileOpen: Bool {
        currentFileURL != nil
    }

    var canApply: Bool {
        isFileOpen && editedWidth > 0 && editedHeight > 0
    }

    var currentPathText: String {
        currentFileURL?.path ?? "No file selected"
    }

    var defaultDirectoryURL: URL {
        service.defaultConfigURL.deletingLastPathComponent()
    }

    func loadDefaultConfigIfAvailable() {
        guard currentFileURL == nil else {
            return
        }

        guard let url = service.defaultConfigURLIfExists() else {
            statusMessage = "Default Setting.cfg was not found. Choose the file manually."
            statusKind = .info
            return
        }

        loadConfig(from: url, source: .automatic)
    }

    func loadConfig(from url: URL, source: ConfigSource = .manual) {
        do {
            let config = try service.loadConfig(from: url)
            applyLoadedConfig(config)
            isFileSaved = true

            switch source {
            case .automatic:
                statusMessage = "Default Setting.cfg found automatically."
            case .manual:
                statusMessage = "Setting.cfg loaded successfully."
            }
            statusKind = .success
        } catch {
            isFileSaved = false
            statusMessage = error.localizedDescription
            statusKind = .error
        }
    }

    func selectPreset(_ preset: ResolutionPreset) {
        selectedPreset = preset
        guard let resolution = preset.resolution else {
            markUnsaved()
            return
        }

        isUpdatingFields = true
        editedWidth = resolution.width
        editedHeight = resolution.height
        isUpdatingFields = false
        markUnsaved()
    }

    func markWidthEdited(_ width: Int) {
        editedWidth = width
        selectedPreset = ResolutionPreset.matching(width: editedWidth, height: editedHeight)
        markUnsaved()
    }

    func markHeightEdited(_ height: Int) {
        editedHeight = height
        selectedPreset = ResolutionPreset.matching(width: editedWidth, height: editedHeight)
        markUnsaved()
    }

    func applyChanges() {
        guard let fileURL = currentFileURL else {
            statusMessage = "Choose a Setting.cfg file first."
            statusKind = .error
            return
        }

        do {
            let backupURL = try service.saveConfig(to: fileURL, width: editedWidth, height: editedHeight)
            isFileSaved = true
            statusMessage = "Settings applied. Backup saved to \(backupURL.lastPathComponent)."
            statusKind = .success
        } catch {
            isFileSaved = false
            statusMessage = error.localizedDescription
            statusKind = .error
        }
    }

    private func applyLoadedConfig(_ config: SettingConfig) {
        currentFileURL = config.url
        isUpdatingFields = true
        editedWidth = config.width
        editedHeight = config.height
        selectedPreset = ResolutionPreset.matching(width: config.width, height: config.height)
        isUpdatingFields = false
    }

    private func markUnsaved() {
        guard !isUpdatingFields, isFileOpen else {
            return
        }

        isFileSaved = false
        if editedWidth <= 0 || editedHeight <= 0 {
            statusMessage = "Width and height must both be greater than 0."
            statusKind = .error
        } else {
            statusMessage = "Ready to apply changes."
            statusKind = .info
        }
    }
}

enum ConfigSource {
    case automatic
    case manual
}
