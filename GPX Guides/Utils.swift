//
//  Utils.swift
//  GPX Guides
//
//  Created by Steven Duzevich on 16/1/2024.
//

import Foundation

func writeGPX(guideLocations: [[String: Any]]) -> String {
    let xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    let gpxHeader = "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" version=\"1.1\" creator=\"GPX Guides\">\n"
    let gpxFooter = "</gpx>\n"
    var gpxBody = ""
    for location in guideLocations {
        gpxBody += "\t<wpt lat=\"\(location["latitude"]!)\" lon=\"\(location["longitude"]!)\">\n"
        gpxBody += "\t\t<name>\(location["title"]!)</name>\n"
        gpxBody += "\t</wpt>\n"
    }
    let gpx = xmlHeader + gpxHeader + gpxBody + gpxFooter
    return gpx
}

func fetchGuideLocations(guideURL: String, completion: @escaping ([[String: Any]]) -> Void) {
    guard let url = URL(string: guideURL) else {
        print("Invalid URL")
        completion([])
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            completion([])
            return
        }

        if let httpContent = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                completion(extractAnnotationsJSON(httpContent: httpContent))
            }
        }
    }.resume()
}

func extractAnnotationsJSON(httpContent: String) -> [[String: Any]] {
    do {
        let pattern = #"\<script id\="shell-props" type\="application/json"\>(.*?)\</script\>"#
        let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let range = NSRange(httpContent.startIndex..<httpContent.endIndex, in: httpContent)

        if let match = regex.firstMatch(in: httpContent, options: [], range: range) {
            let matchRange = match.range(at: 1)
            if let swiftRange = Range(matchRange, in: httpContent) {
                if let jsonData = httpContent[swiftRange].data(using: .utf8), let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any], let initialState = jsonObject["initialState"] as? [String: Any], let map = initialState["map"] as? [String: Any], let annotations = map["annotations"] as? [[String: Any]] {
                    var guideLocations: [[String: Any]] = []
                    for annotation in annotations {
                        let title = annotation["title"]!
                        let coordinates = (annotation["center"] as? NSArray)!
                        guideLocations.append(["title": title, "latitude": coordinates[0], "longitude": coordinates[1]])
                    }
                    return guideLocations
                }
            }
        }
    } catch {
        print("Error creating regular expression: \(error)")
    }
    return []
}
