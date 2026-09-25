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
}


private func parseTextIntoColumns(receivedText: String?) -> [(String, String)] {
    guard let text = receivedText else { return [] }
    
    return text.split(whereSeparator: \.isNewline).compactMap { parseWordPair(String($0)) }
}

private func parseWordPair(_ line: String) -> (String, String)? {
    let separators = ["\t", ";", ",", " - ", "–", "—", "-"]
    for separator in separators {
        guard let range = line.range(of: separator) else { continue }
        let word = line[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        let translation = line[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty, !translation.isEmpty else { return nil }
        return (word, translation)
    }
    return nil
}

func loadSharedWordPairs() -> [(String, String)]? {
    guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.at.flashcards") else {
        print("Failed to access shared container")
        return nil
    }
    
    let fileURL = sharedContainerURL.appendingPathComponent("sharedData.txt")
    
    do {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        return parseTextIntoColumns(receivedText: content)
    } catch {
        print("Error loading shared file: \(error)")
        return nil
    }
}

func getQueryStringParameter(url: String, param: String) -> String? {
  guard let url = URLComponents(string: url) else { return nil }
  return url.queryItems?.first(where: { $0.name == param })?.value
}
