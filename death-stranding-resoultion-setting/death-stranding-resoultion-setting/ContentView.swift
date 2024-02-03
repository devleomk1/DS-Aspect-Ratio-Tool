//
//  ContentView.swift
//  death-stranding-resoultion-setting
//
//  Created by 강지순 on 2/3/24.
//

import SwiftUI

struct ContentView: View {
    @State var isShowing = false
    var body: some View {
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Death Stranding Diplay Ratio")
            
            Button(action: {
                isShowing.toggle()
                openFile()
            }, label: {
                Text("16:10")
            })
            
        }
        .padding()
        .onAppear{
            changeText()
        }
    }
    func changeText() {
        let fileManager: FileManager = FileManager.default
        let downloadPath: URL = fileManager.urls(for: .downloadsDirectory, in: .allDomainsMask)[0]
        let textfilePath: URL = downloadPath.appendingPathComponent("test-ds")
        
        do {
            let dataFromPath: Data = try Data(contentsOf: textfilePath)
            let text: String = String(data: dataFromPath, encoding: .utf8) ?? "EMPTY FILE!"
            print(text)
        } catch let e {
            print(e.localizedDescription)
        }

    }
    
    func openFile() {
        let openPanel = NSOpenPanel()
        let libraryPath: URL = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask)[0]
        let dsConfigFilePath: URL = libraryPath.appendingPathComponent("Containers/com.505games.deathstranding/Data/")
        
        openPanel.begin { response in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let fileURL = openPanel.url {
                    do {
                        var fileText = try String(contentsOf: fileURL)
                        
                        fileText.append("\nHello World")
                        try fileText.write(to: fileURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("Error reading file: \(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
}



#Preview {
    ContentView()
}
