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
    
    @State var openFilePath: URL?
    @State var fileText: String = ""
    
    @State var edited_height: String = ""
    @State var edited_width: String = ""
    @State var origin_height: String = ""
    @State var origin_width: String = ""
    
    @State var selected_num: Int = 1
    
    let rendering_width: String = "rendering_width"
    let rendering_height: String = "rendering_height"
    
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
            Divider()
            
                
            Text("Select Mac Screen")
                .font(.headline)
            Picker(selection: $selected_num, label: Text("Select My Mac")) {
                Text("MacBook Air 13-inch with M1").tag(1)
                Text("MacBook Air 13-inch with M2").tag(2)
                Text("MacBook Air 15-inch").tag(3)
                Divider()
                Text("MacBook Pro 14-inch").tag(4)
                Text("MacBook Pro 16-inch").tag(5)
                Divider()
                Text("Custom").tag(6)
            }
            .disabled(!isFileOpen)
            
            
            Text("Display Resolution")
                .font(.headline)
            HStack(){
                TextField("width", text: $edited_width)
                Text("x")
                TextField("height", text: $edited_height)
            }.disabled(!isFileOpen)
            
            HStack(){
                Button(action: {
                    saveFile()
                }, label: {
                    Text("Save")
                })
                .disabled(!isFileOpen)
                if (!isFileOpen) {
                    Text("Need to open the Setting.cfg file")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
    
    func saveFile() {
        if let fileURL = openFilePath {
            do {
                var origin_width_line: String = ""
                var origin_height_line: String = ""
                
                let edited_width_line: String = combinePrefixAndSuffix(pre: rendering_width, suf: edited_width)
                let edited_height_line: String = combinePrefixAndSuffix(pre: rendering_height, suf: edited_height)

                let getLines = fileText.components(separatedBy: .newlines)
                for line in getLines {
                    if (line.contains(rendering_width)){
                        origin_width_line = line
                    }
                    else if (line.contains(rendering_height)){
                        origin_height_line = line
                    }
                }
                
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
                        isFileOpen = true
                        
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
