//
//  fileParser.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-25.
//

import Foundation
import UniformTypeIdentifiers

func parseFileToWordPairs(file: URL) -> [(String, String)]? {
    do {
        // Read the file content as a string
        let content = try String(contentsOf: file, encoding: .utf8)
        return parseTextIntoColumns(receivedText: content)
    } catch {
        print("Failed to read file: \(error.localizedDescription)")
        return loadSharedWordPairs()
    }
    return nil
}


private func parseTextIntoColumns(receivedText: String?) -> [(String, String)] {
    guard let text = receivedText else { return [] }
    
    // Split the text into lines
    let lines = text.split(whereSeparator: \.isNewline).map { String($0) }
    
    var wordPairs: [(String, String)] = []
    
    // Define delimiters
    let delimiters = ["\t", "-", ";", ","]
    
    // Parse each line
    for line in lines {
        // Split the line using the defined delimiters
        let components = line.components(separatedBy: CharacterSet(charactersIn: delimiters.joined()))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        if components.count >= 2 {
            // Store the first two trimmed components as a tuple in wordPairs
            wordPairs.append((components[0], components[1]))
        }
    }
    
    return wordPairs
}


func loadSharedWordPairs() -> [(String, String)]? {
    guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.at.flashcards") else {
        print("Failed to access shared container")
        return nil
    }
    
    let fileURL = sharedContainerURL.appendingPathComponent("sharedData.txt")
    
    do {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.split(separator: "\n")
        
        // Parse each line into a tuple and store in array
        let wordPairs = lines.compactMap { line -> (String, String)? in
            let components = line.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
            return components.count == 2 ? (components[0], components[1]) : nil
        }
        
        return wordPairs
    } catch {
        print("Error loading shared file: \(error)")
        return nil
    }
}

func getQueryStringParameter(url: String, param: String) -> String? {
  guard let url = URLComponents(string: url) else { return nil }
  return url.queryItems?.first(where: { $0.name == param })?.value
}
