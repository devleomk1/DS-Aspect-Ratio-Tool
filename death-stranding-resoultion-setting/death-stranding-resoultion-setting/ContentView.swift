//
//  ContentView.swift
//  death-stranding-resoultion-setting
//
//  Created by 강지순 on 2/3/24.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
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
}



#Preview {
    ContentView()
}
