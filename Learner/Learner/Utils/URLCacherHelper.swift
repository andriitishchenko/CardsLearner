//
//  URLCacherHelper.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-22.
//

import Foundation
import CryptoKit

func downloadFileDataTask(urlString: String) async -> URL? {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }
    
    if url.isFileURL {
        return url
    }
    guard let scheme = url.scheme?.lowercased(),
          ["http", "https"].contains(scheme),
          url.host != nil else {
        print("Invalid URL")
        return nil
    }

    // Determine the destination URL in the caches directory
    let documentsUrl: URL
    do {
        documentsUrl = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    } catch {
        print("Error getting caches directory: \(error.localizedDescription)")
        return nil
    }
    
    let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        .map { String(format: "%02x", $0) }
        .joined()
    let filename = digest + (url.pathExtension.isEmpty ? "" : ".\(url.pathExtension)")
    let destinationUrl = documentsUrl.appendingPathComponent(filename)
    
    // Check if the file already exists locally
    if FileManager.default.fileExists(atPath: destinationUrl.path) {
        return destinationUrl
    }
    
    // If the file doesn't exist, download it
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    do {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Download failed with status code: \(response.debugDescription)")
            return nil
        }
        try data.write(to: destinationUrl, options: .atomic)
        return destinationUrl
    } catch {
        print("Error during download: \(error.localizedDescription)")
    }

    return nil
}
