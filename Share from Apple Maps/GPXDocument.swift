//
//  GPXDocument.swift
//  GPX Guides
//
//  Created by Steven Duzevich on 15/1/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct GPXDocument: FileDocument {
    static var readableContentTypes = [UTType(filenameExtension: "gpx")!]

    var text = ""

    init(initialText: String = "") {
        text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
