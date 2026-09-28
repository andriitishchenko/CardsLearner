import Foundation

enum WordPairParser {
    private static let separators = ["\t", ";", ",", " - ", "–", "—", "-"]

    static func parse(_ text: String) -> [(String, String)] {
        text.split(whereSeparator: \.isNewline).compactMap { line in
            for separator in separators {
                guard let range = line.range(of: separator) else { continue }
                let word = line[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                let translation = line[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                guard !word.isEmpty, !translation.isEmpty else { return nil }
                return (word, translation)
            }
            return nil
        }
    }
}
