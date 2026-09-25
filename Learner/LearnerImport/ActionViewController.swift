import UIKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class ActionViewController: UIViewController {

    var receivedText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        extractTextOrFileFromInput()
    }

    private func extractTextOrFileFromInput() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            showErrorView()
            return
        }

        let providers = inputItems.flatMap { $0.attachments ?? [] }
        guard let attachment = providers.first(where: {
            $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
                || $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }) else {
            showErrorView()
            return
        }

        let typeIdentifier = attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
            ? UTType.plainText.identifier
            : UTType.fileURL.identifier

        attachment.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] data, error in
            guard error == nil else {
                Task { @MainActor [weak self] in self?.showErrorView() }
                return
            }

            let text: String?
            if typeIdentifier == UTType.plainText.identifier {
                text = data as? String
            } else if let fileURL = data as? URL {
                text = try? String(contentsOf: fileURL, encoding: .utf8)
            } else {
                text = nil
            }

            Task { @MainActor [weak self] in
                guard let self, let text else {
                    self?.showErrorView()
                    return
                }
                self.receivedText = text
                self.showActionView()
            }
        }
    }

    private func parseTextIntoColumns() -> [(String, String)] {
        guard let text = receivedText else { return [] }
        
        return text.split(whereSeparator: \.isNewline).compactMap { line in
            for separator in ["\t", ";", ",", " - ", "–", "—", "-"] {
                guard let range = line.range(of: separator) else { continue }
                let word = line[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                let translation = line[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                guard !word.isEmpty, !translation.isEmpty else { return nil }
                return (word, translation)
            }
            return nil
        }
    }

    private func showActionView() {
        let wordPairs = parseTextIntoColumns() // Get the word pairs
        guard !wordPairs.isEmpty else {
            showErrorView()
            return
        }
        
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

        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.at.flashcards") else {
            return nil
        }

        let fileURL = sharedContainerURL.appendingPathComponent("sharedData.txt")
        do {
            try contentText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving shared import: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func notifyHostAppOfNewData(url:URL) {
        let sharedDefaults = UserDefaults(suiteName: "group.at.flashcards")
        sharedDefaults?.set(url.absoluteString, forKey: "IMPORT_PATH")
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
