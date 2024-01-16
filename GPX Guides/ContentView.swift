//
//  ContentView.swift
//  GPX Guides
//
//  Created by Steven Duzevich on 15/1/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var guideURL = ""
    @State private var showExporter = false
    @State private var document: GPXDocument = GPXDocument()
    @State private var guideLocations: [[String: Any]] = []
    
    var body: some View {
        Text("found \(guideLocations.count) location(s).")
            .fileExporter(isPresented: $showExporter, document: document, contentType: UTType(filenameExtension: "gpx")!) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                reset()
            }
        if guideLocations.count != 0 {
            Button(action: {
                document.text = writeGPX(guideLocations: (guideLocations))
                showExporter = true
            }, label: {
                Text("Save")
            })
        } else {
            PasteButton(payloadType: URL.self) { urls in
                guard let first = urls.first else { return }
                guideURL = first.absoluteString
                fetchGuideLocations(guideURL: guideURL) { locations in
                    guideLocations = locations
                }
            }
        }
    }
    
    func reset() {
        guideURL = ""
        guideLocations = []
        showExporter = false
    }
}

#Preview {
    ContentView()
}


