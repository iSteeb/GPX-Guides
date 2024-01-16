//
//  ShareExtensionView.swift
//  Share from Apple Maps
//
//  Created by Steven Duzevich on 15/1/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShareExtensionView: View {
    @State private var guideURL: String
    @State private var showExporter = false
    @State private var document: GPXDocument = GPXDocument()
    @State private var guideLocations: [[String: Any]] = []
    
    init(guideURL: String) {
        self.guideURL = guideURL
    }
    
    var body: some View {
        Text("Test")
            .onAppear(perform: {
                fetchGuideLocations(guideURL: guideURL) { locations in
                    guideLocations = locations
                }
            })
        if guideLocations.count != 0 {
            VStack {
                Text("found \(guideLocations.count) location(s).")
                    .fileExporter(isPresented: $showExporter, document: document, contentType: UTType(filenameExtension: "gpx")!) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                        close()
                    }
                Button(action: {
                    document.text = writeGPX(guideLocations: (guideLocations))
                    showExporter = true
                }, label: {
                    Text("Save")
                })
            }
        }
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
