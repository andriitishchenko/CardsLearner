import UIKit
import MobileCoreServices
import SwiftUI

class ActionViewController: UIViewController {

    var receivedText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractTextOrFileFromInput()
    }

    private func extractTextOrFileFromInput() {
        // Ensure we have input items from the extension context
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] else {
            DispatchQueue.main.async {
                self.showErrorView()
            }
            return
        }
        
        for item in inputItems {
            guard let attachments = item.attachments else { continue }
            
            for attachment in attachments {
                // First, attempt to handle plain text
                if attachment.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { (data, error) in
                        if let text = data as? String {
                            self.receivedText = text
                            print("Received text: \(text)")
                            
                            DispatchQueue.main.async {
                                self.showActionView()
                            }
                        } else {
                            // Attempt to handle as a file if text fails
                            self.handleFileAttachment(attachment)
                        }
                    }
                } else {
                    // Handle file attachments if they are not plain text
                    handleFileAttachment(attachment)
                }
            }
        }
    }

    // Helper function to process file attachments
    private func handleFileAttachment(_ attachment: NSItemProvider) {
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeFileURL as String) {
            attachment.loadItem(forTypeIdentifier: kUTTypeFileURL as String, options: nil) { (data, error) in
                if let fileURL = data as? URL {
                    // Process the file URL as needed
                    self.processFile(at: fileURL)
                    
                    DispatchQueue.main.async {
                        self.showActionView()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showErrorView()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showErrorView()
            }
        }
    }

    // Additional function to handle file processing
    private func processFile(at url: URL) {
        do {
            // Example: Read file content as text
            let fileContent = try String(contentsOf: url, encoding: .utf8)
            self.receivedText = fileContent
            print("Received file content: \(fileContent)")
        } catch {
            print("Failed to read file content: \(error)")
            DispatchQueue.main.async {
                self.showErrorView()
            }
        }
    }

    private func parseTextIntoColumns() -> [(String, String)] {
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

    private func showActionView() {
        let wordPairs = parseTextIntoColumns() // Get the word pairs
        
        let actionView = ActionView(wordPairs: wordPairs) {
            // Handle continue action
            if let urlPath = self.saveToSharedFile(wordPairs: wordPairs){
                self.notifyHostAppOfNewData(url:urlPath)
                self.openHostApp()
            }
            // Dismiss the extension when done
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        let hostingController = UIHostingController(rootView: actionView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.layer.cornerRadius = 16
        
        // Add the hostingController as a child view controller
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Define auto-layout constraints
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.7),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
    }
    
    
    private func showErrorView() {
        let errorMessage = "Unable to parse into columns."
        let errorView = ErrorActionView(errorMessage: errorMessage) {
            // Handle close action
            self.dismissErrorView()
        }
        
        let hostingController = UIHostingController(rootView: errorView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the error view as a child view controller
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Center the error view on screen
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            hostingController.view.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func dismissErrorView() {
        // Remove any existing error view from the view hierarchy
        if let errorVC = children.first(where: { $0 is UIHostingController<ErrorActionView> }) {
            errorVC.willMove(toParent: nil)
            errorVC.view.removeFromSuperview()
            errorVC.removeFromParent()
        }
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    
    private func saveToSharedFile(wordPairs: [(String, String)]) -> URL? {
        // Convert word pairs to a single string with each pair on a new line
        let contentText = wordPairs.map { "\($0.0) - \($0.1)" }.joined(separator: "\n")

        var fileURL: URL?
        // Get the shared container URL
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.at.flashcards") {
            fileURL = sharedContainerURL.appendingPathComponent("sharedData.txt")

            do {
                // Write the formatted content to the file
                try contentText.write(to: fileURL!, atomically: true, encoding: .utf8)
                print("Data saved to shared file at \(fileURL)")
            } catch {
                print("Error saving file: \(error)")
            }
        }
        return fileURL
    }
    
    private func notifyHostAppOfNewData(url:URL) {
        let sharedDefaults = UserDefaults(suiteName: "group.at.flashcards")
        sharedDefaults?.set(url, forKey: "IMPORT_PATH") // Store the current date
        sharedDefaults?.synchronize() // Ensure changes are saved
    }
    
    private func openHostApp() {
        if let url = URL(string: "lrnwcards://") {
            self.openURL(url)
        }
    }

    @objc @discardableResult private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                if #available(iOS 18.0, *) {
                    application.open(url, options: [:], completionHandler: nil)
                    return true
                } else {
                    return application.perform(#selector(openURL(_:)), with: url) != nil
                }
            }
            responder = responder?.next
        }
        return false
    }
}


