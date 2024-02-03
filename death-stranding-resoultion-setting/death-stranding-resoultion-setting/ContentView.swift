//
//  ContentView.swift
//  death-stranding-resoultion-setting
//
//  Created by 강지순 on 2/3/24.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @State var isShowing = false
    @State var isFileOpen = false
    @State var configValue: [String: String] = [:]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack(){
                Text("Config file data")
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(action: {
                    isShowing.toggle()
                    openFile()
                }, label: {
                    Text("Open file")
                })
            }
            List {
                ForEach(configValue.sorted(by: <), id: \.key) { key, value in
                    Text("\(key): \(value)")
                }
            }
            
            Button(action: {
                changeData()
            }, label: {
                Text("HDR off")
            })
            .disabled(false)
            
            
        }
        .padding()
    }
    func changeData() {
        configValue.updateValue("\"0\"", forKey: "\"hdr\"")
        print("change!")
        
        
    }
    
    func openFile() {
        let openPanel = NSOpenPanel()
        let libraryPath: URL = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask)[0]
        let dsConfigFilePath: URL = libraryPath.appendingPathComponent("Containers/com.505games.deathstranding/Data/")
        
        openPanel.directoryURL = dsConfigFilePath
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowedContentTypes = [.cfg]
        openPanel.begin { response in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let fileURL = openPanel.url {
                    do {
                        var fileText = try String(contentsOf: fileURL)
                        
                        let getLines = fileText.components(separatedBy: .newlines)
                        
                        for line in getLines {
                            let components = line.components(separatedBy: .whitespaces)
                            if (components.count == 2) {
                                let key = components[0]
                                let value = components[1]
                                configValue[key] = value
                            }
                        }
                        
//                        fileText.append("\nHello World")
//                        try fileText.write(to: fileURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("Error reading file: \(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
}

extension UTType {
    public static let cfg = UTType(exportedAs: "com.domain.cfg")
}

#Preview {
    ContentView()
}
