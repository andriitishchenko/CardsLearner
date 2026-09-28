//
//  fileParser.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-25.
//

import Foundation

func parseFileToWordPairs(file: URL) -> [(String, String)]? {
    do {
        // Read the file content as a string
        let content = try String(contentsOf: file, encoding: .utf8)
        return WordPairParser.parse(content)
    } catch {
        print("Failed to read file: \(error.localizedDescription)")
        return nil
    }
}
func getQueryStringParameter(url: String, param: String) -> String? {
  guard let url = URLComponents(string: url) else { return nil }
  return url.queryItems?.first(where: { $0.name == param })?.value
}
