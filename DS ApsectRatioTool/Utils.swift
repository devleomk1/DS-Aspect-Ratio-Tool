//
//  Utils.swift
//  DS Aspect Ratio Tool
//
//  Created by 강지순 on 2/4/24.
//

import Foundation

struct Resolution: Equatable {
    let width: Int
    let height: Int
}

enum ResolutionPreset: Int, CaseIterable, Identifiable {
    case custom = 0
    case macBookPro16
    case macBookPro14
    case macBookAir15
    case macBookAir13
    case standard1680
    case standard1280

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .custom:
            return "Custom"
        case .macBookPro16:
            return "3456 x 2160 (MacBook Pro 16-inch)"
        case .macBookPro14:
            return "3024 x 1890 (MacBook Pro 14-inch)"
        case .macBookAir15:
            return "2880 x 1800 (MacBook Air 15-inch)"
        case .macBookAir13:
            return "2560 x 1600 (MacBook Air 13-inch)"
        case .standard1680:
            return "1680 x 1050"
        case .standard1280:
            return "1280 x 800"
        }
    }

    var resolution: Resolution? {
        switch self {
        case .custom:
            return nil
        case .macBookPro16:
            return Resolution(width: 3456, height: 2160)
        case .macBookPro14:
            return Resolution(width: 3024, height: 1890)
        case .macBookAir15:
            return Resolution(width: 2880, height: 1800)
        case .macBookAir13:
            return Resolution(width: 2560, height: 1600)
        case .standard1680:
            return Resolution(width: 1680, height: 1050)
        case .standard1280:
            return Resolution(width: 1280, height: 800)
        }
    }

    static func matching(width: Int, height: Int) -> ResolutionPreset {
        for preset in ResolutionPreset.allCases {
            guard let resolution = preset.resolution else {
                continue
            }
            if resolution.width == width && resolution.height == height {
                return preset
            }
        }
        return .custom
    }
}
