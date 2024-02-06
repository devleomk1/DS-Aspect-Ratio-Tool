//
//  death_stranding_resoultion_settingApp.swift
//  death-stranding-resoultion-setting
//
//  Created by 강지순 on 2/3/24.
//

import SwiftUI



@main
struct death_stranding_resoultion_settingApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, maxWidth: 500, minHeight: 400 , maxHeight: 400)
        }.windowResizabilityContentSize()
    }
    
}

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}

