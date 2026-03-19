//
//  ConfigFileService.swift
//  DS Aspect Ratio Tool
//
//  Created by Codex on 3/19/26.
//

import Foundation

struct SettingConfig {
    let url: URL
    let width: Int
    let height: Int
}

enum ConfigFileError: LocalizedError {
    case fileNotFound(URL)
    case missingKey(String)
    case invalidValue(String)
    case invalidDimensions

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "Could not find Setting.cfg at \(url.path)."
        case .missingKey(let key):
            return "The config file does not contain '\(key)'."
        case .invalidValue(let key):
            return "The config file contains an invalid value for '\(key)'."
        case .invalidDimensions:
            return "Width and height must both be greater than 0."
        }
    }
}

struct ConfigFileService {
    let fileManager: FileManager = .default

    private let renderingWidthKey = "rendering_width"
    private let renderingHeightKey = "rendering_height"
    private let configLineRegex = try? NSRegularExpression(pattern: #"^\s*"([^"]+)"\s+"([^"]*)"\s*$"#)

    var defaultConfigURL: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Containers/com.505games.deathstranding/Data/Setting.cfg")
    }

    func defaultConfigURLIfExists() -> URL? {
        let defaultURL = defaultConfigURL
        guard fileManager.fileExists(atPath: defaultURL.path) else {
            return nil
        }
        return defaultURL
    }

    func loadConfig(from url: URL) throws -> SettingConfig {
        guard fileManager.fileExists(atPath: url.path) else {
            throw ConfigFileError.fileNotFound(url)
        }

        let text = try String(contentsOf: url)
        let values = try extractValues(from: text)

        guard let width = values[renderingWidthKey] else {
            throw ConfigFileError.missingKey(renderingWidthKey)
        }
        guard let height = values[renderingHeightKey] else {
            throw ConfigFileError.missingKey(renderingHeightKey)
        }

        return SettingConfig(url: url, width: width, height: height)
    }

    @discardableResult
    func saveConfig(to url: URL, width: Int, height: Int) throws -> URL {
        guard width > 0, height > 0 else {
            throw ConfigFileError.invalidDimensions
        }

        let originalText = try String(contentsOf: url)
        let updatedText = try updatingConfigText(originalText, width: width, height: height)
        let backupURL = url.appendingPathExtension("bak")

        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }
        try fileManager.copyItem(at: url, to: backupURL)
        try updatedText.write(to: url, atomically: true, encoding: .utf8)

        return backupURL
    }

    private func extractValues(from text: String) throws -> [String: Int] {
        var values: [String: Int] = [:]

        for line in text.components(separatedBy: .newlines) {
            guard let (key, value) = parseConfigLine(line) else {
                continue
            }

            if key == renderingWidthKey || key == renderingHeightKey {
                guard let intValue = Int(value) else {
                    throw ConfigFileError.invalidValue(key)
                }
                values[key] = intValue
            }
        }

        return values
    }

    private func updatingConfigText(_ text: String, width: Int, height: Int) throws -> String {
        var didUpdateWidth = false
        var didUpdateHeight = false

        let updatedLines = text.components(separatedBy: .newlines).map { line in
            guard let (key, _) = parseConfigLine(line) else {
                return line
            }

            switch key {
            case renderingWidthKey:
                didUpdateWidth = true
                return formattedLine(key: key, value: String(width))
            case renderingHeightKey:
                didUpdateHeight = true
                return formattedLine(key: key, value: String(height))
            default:
                return line
            }
        }

        guard didUpdateWidth else {
            throw ConfigFileError.missingKey(renderingWidthKey)
        }
        guard didUpdateHeight else {
            throw ConfigFileError.missingKey(renderingHeightKey)
        }

        return updatedLines.joined(separator: "\n")
    }

    private func formattedLine(key: String, value: String) -> String {
        "\"\(key)\" \"\(value)\""
    }

    private func parseConfigLine(_ line: String) -> (String, String)? {
        guard let regex = configLineRegex else {
            return nil
        }

        let range = NSRange(line.startIndex..<line.endIndex, in: line)
        guard let match = regex.firstMatch(in: line, options: [], range: range),
              match.numberOfRanges == 3,
              let keyRange = Range(match.range(at: 1), in: line),
              let valueRange = Range(match.range(at: 2), in: line) else {
            return nil
        }

        return (String(line[keyRange]), String(line[valueRange]))
    }
}
