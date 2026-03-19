//
//  ContentView.swift
//  DS Aspect Ratio Tool
//
//  Created by 강지순 on 2/3/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.zeroSymbol = ""
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            fileSection
            resolutionSection
        }
        .padding()
        .onAppear {
            viewModel.loadDefaultConfigIfAvailable()
        }
    }

    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DS Aspect Ratio Tool")
                    .font(.title)
                Text("DEATH STRANDING Director's Cut for macOS")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var fileSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("Setting File")
                    .font(.headline)
                Text("The app tries to find the default Setting.cfg automatically. You can still choose a different file manually.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                LabeledContent("Current file") {
                    Text(viewModel.currentPathText)
                        .font(.caption)
                        .foregroundStyle(viewModel.isFileOpen ? .primary : .secondary)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Button("Choose file...") {
                        openFilePanel()
                    }

                    if viewModel.isFileOpen {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }

                    Spacer()
                }

                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }
            .padding(6)
        }
    }

    private var resolutionSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Picker(
                    "Select display resolution",
                    selection: Binding(
                        get: { viewModel.selectedPreset },
                        set: { viewModel.selectPreset($0) }
                    )
                ) {
                    ForEach(ResolutionPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .disabled(!viewModel.isFileOpen)

                HStack {
                    TextField(
                        "width",
                        value: Binding(
                            get: { viewModel.editedWidth },
                            set: { viewModel.markWidthEdited($0) }
                        ),
                        formatter: formatter
                    )
                    .textFieldStyle(.roundedBorder)

                    Text("x")

                    TextField(
                        "height",
                        value: Binding(
                            get: { viewModel.editedHeight },
                            set: { viewModel.markHeightEdited($0) }
                        ),
                        formatter: formatter
                    )
                    .textFieldStyle(.roundedBorder)
                }
                .disabled(!viewModel.isFileOpen || viewModel.selectedPreset != .custom)

                HStack {
                    Button("Apply") {
                        viewModel.applyChanges()
                    }
                    .disabled(!viewModel.canApply)

                    if viewModel.isFileSaved && viewModel.isFileOpen {
                        Text("Current values are saved.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if !viewModel.isFileOpen {
                        Text("Open a Setting.cfg file to edit the resolution.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
            .padding(6)
        }
    }

    private var statusColor: Color {
        switch viewModel.statusKind {
        case .info:
            return .secondary
        case .success:
            return .green
        case .error:
            return .red
        }
    }

    private func openFilePanel() {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = viewModel.defaultDirectoryURL
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowedContentTypes = [.cfg]

        openPanel.begin { response in
            guard response == .OK, let fileURL = openPanel.url else {
                return
            }

            Task { @MainActor in
                viewModel.loadConfig(from: fileURL, source: .manual)
            }
        }
    }
}

extension UTType {
    static let cfg = UTType(exportedAs: "com.domain.cfg")
}

#Preview {
    ContentView()
}
