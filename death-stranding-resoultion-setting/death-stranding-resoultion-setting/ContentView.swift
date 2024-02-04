//
//  ContentView.swift
//  death-stranding-resoultion-setting
//
//  Created by 강지순 on 2/3/24.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @State var isShowing: Bool = false
    @State var isFileOpen: Bool = false
    @State var configValue: [String: String] = [:]
    @State var openFilePath: URL?
    @State var fileText: String = ""
    
    @State var edited_height: String = ""
    @State var edited_width: String = ""
    @State var origin_height: String = ""
    @State var origin_width: String = ""
    
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
            Spacer()
            Text("Display Resoultion")
                .font(.headline)
            HStack(){
                TextField("width", text: $edited_width)
                Text("x")
                TextField("height", text: $edited_height)
            }.disabled(false)
            
            Button(action: {
                saveFile()
            }, label: {
                Text("Save")
            })
            .disabled(false)
            
            
        }
        .padding()
    }
    func combinePrefixAndSuffix(pre: String, suf: String) -> String {
        return pre + "\"" + suf + "\""
    }
    
    func saveFile() {
        if let fileURL = openFilePath {
            do {
                let prefix_width: String = "\"rendering_width\" "
                let prefix_height: String = "\"rendering_height\" "
                let origin_width_line: String = combinePrefixAndSuffix(pre: prefix_width, suf: origin_width)
                let origin_height_line: String = combinePrefixAndSuffix(pre: prefix_height, suf: origin_height)
                let edited_width_line: String = combinePrefixAndSuffix(pre: prefix_width, suf: edited_width)
                let edited_height_line: String = combinePrefixAndSuffix(pre: prefix_height, suf: edited_height)
                
                fileText = fileText.replacingOccurrences(of: origin_width_line, with: edited_width_line)
                fileText = fileText.replacingOccurrences(of: origin_height_line, with: edited_height_line)
                
                try fileText.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch let e {
                print(e.localizedDescription)
            }
        }
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
                        fileText = try String(contentsOf: fileURL)
                        openFilePath = fileURL
                        
                        let getLines = fileText.components(separatedBy: .newlines)
                        for line in getLines {
                            if (line.contains("rendering_width"))
                            {
                                let components = line.components(separatedBy: .whitespaces)
                                if (components.count == 2) {
                                    origin_width = components[1].replacingOccurrences(of: "\"", with: "")
                                    edited_width = origin_width
                                }
                            }
                            if (line.contains("rendering_height"))
                            {
                                let components = line.components(separatedBy: .whitespaces)
                                if (components.count == 2) {
                                    origin_height = components[1].replacingOccurrences(of: "\"", with: "")
                                    edited_height = origin_height
                                }
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
