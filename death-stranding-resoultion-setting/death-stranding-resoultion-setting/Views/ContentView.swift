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
    @State public var isHelpWindowOpen: Bool = false
    
    @State var openFilePath: URL?
    @State var fileText: String = ""
    
    @State var edited_height: String = ""
    @State var edited_width: String = ""
    @State var origin_height: String = ""
    @State var origin_width: String = ""
    
    @State var selected_num: Int = 0
    
    @State private var availableResolutions: [String] = []
    
    let rendering_width: String = "rendering_width"
    let rendering_height: String = "rendering_height"
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .bottom){
                VStack(alignment: .leading){
                    Text("16:10 Display Setting Tool")
                        .font(.title)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing)
                    Text("DEATH STRANDING Director's Cut for macOS")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .padding(.bottom)
                }.padding([.top, .leading, .bottom])
                Spacer()
            }
            
            
            
            GroupBox(){
                VStack(alignment: .leading){
                    Text("Open Setting File")
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    Text("Open the 'Setting.cfg' file to change the resolution and aspect ratio.")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
           
//                    TextField("", text: .constant("/Users/{USER_NAME}/Library/Containers/com.505games.deathstranding/Data/Setting.cfg"))
//                        .font(.subheadline)
//                        .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    
                    Divider()
                    HStack(){
                        Spacer()
                        if (isFileOpen){
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.green)
                        }
                        Button(action: {
                            isShowing.toggle()
                            openFile()
                        }, label: {
                            Text("Open file...")
                        })
                    }
                    .padding(.top, -1.0)
                }
                .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
            }.padding([.leading, .trailing])
            
            
            GroupBox(){
                Picker(selection: $selected_num, label: Text("Select display resolution")) {
                    Text("Custom").tag(0)
                    Divider()
                    Text("3456 x 2160 (MacBook Pro 16-inch)").tag(1)
                    Text("3024 x 1890 (MacBook Pro 14-inch)").tag(2)
                    Text("2880 x 1800 (MacBook Air 15-inch)").tag(3)
                    Text("2560 x 1600 (MacBook Air 13-inch)").tag(4)
                    Text("1680 x 1050").tag(5)
                    Text("1280 x 800").tag(6)
                    
                }
                .onChange(of: selected_num, {
                    selectResolution(num: selected_num)
                })
                .disabled(!isFileOpen)
                .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
                
                HStack(){
                    TextField("width", text: $edited_width)
                    Text("x")
                    TextField("height", text: $edited_height)
                }
                .disabled(!isFileOpen || selected_num != 0)
                .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
                
                HStack(){
                    Button(action: {
                        saveFile()
                    }, label: {
                        Text("Apply")
                    })
                    .disabled(!isFileOpen)
                    if (!isFileOpen) {
                        Text("Need to open the Setting.cfg file")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                }.padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
                
                
            }.padding(.all)
            
//            Button("Help") {
//                isHelpWindowOpen.toggle()
//                
//            }
//            .padding([.leading, .bottom])
//            .popover(isPresented: $isHelpWindowOpen, content: {
//                HelpView()
//            })
            
            
        }
        .padding()
        
    }
    
    func selectResolution(num:Int) {
        switch num {
        case 1:
            edited_width = "3456"
            edited_height = "2160"
        case 2:
            edited_width = "3024"
            edited_height = "1890"
        case 3:
            edited_width = "2880"
            edited_height = "1800"
        case 4:
            edited_width = "2560"
            edited_height = "1600"
        case 5:
            edited_width = "1680"
            edited_height = "1050"
        case 6:
            edited_width = "1280"
            edited_height = "800"
        default:
            print("no resolution in list")
        }
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
