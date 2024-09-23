//
//  URLCacherHelper.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-22.
//

import Foundation

func downloadFileDataTask(urlString: String) async -> URL? {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }

    // Determine the destination URL in the caches directory
    let documentsUrl: URL
    do {
        documentsUrl = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    } catch {
        print("Error getting caches directory: \(error.localizedDescription)")
        return nil
    }
    
    let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
    
    // Check if the file already exists locally
    if FileManager.default.fileExists(atPath: destinationUrl.path) {
        return destinationUrl
    }
    
    // If the file doesn't exist, download it
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    do {
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            try data.write(to: destinationUrl)
            return destinationUrl
        } else {
            print("Download failed with status code: \(response.debugDescription)")
        }
    } catch {
        print("Error during download: \(error.localizedDescription)")
    }

    return nil
}
