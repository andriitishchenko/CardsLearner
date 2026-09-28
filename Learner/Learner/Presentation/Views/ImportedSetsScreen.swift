import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ImportedSetsScreen: View {
    @ObservedObject var appIntent: AppIntent
    @State private var isImportingFile = false
    @State private var activeSheet: ImportSheet?

    var body: some View {
        Group {
            if appIntent.importedWordSets.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.book.closed")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No imported words yet")
                        .font(.headline)
                    Text("Add a file, a link, or paste word pairs to get started.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
            } else {
                List {
                    ForEach(appIntent.importedWordSets) { wordSet in
                        Button {
                            appIntent.selectImportedWordSet(wordSet)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(wordSet.importedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(wordSet.preview)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Text("\(wordSet.category.list.count) pairs")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        for index in offsets.sorted(by: >) {
                            appIntent.deleteImportedWordSet(appIntent.importedWordSets[index])
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Imported words")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        isImportingFile = true
                    } label: {
                        Label("From file", systemImage: "doc")
                    }
                    Button {
                        activeSheet = .url
                    } label: {
                        Label("From URL", systemImage: "link")
                    }
                    Button {
                        activeSheet = .text
                    } label: {
                        Label("Paste text", systemImage: "doc.on.clipboard")
                    }
                } label: {
                    Label("Add words", systemImage: "plus")
                }
            }
        }
        .fileImporter(
            isPresented: $isImportingFile,
            allowedContentTypes: [.plainText, .utf8PlainText, .delimitedText, .commaSeparatedText, .tabSeparatedText]
        ) { result in
            switch result {
            case .success(let file):
                let didStartAccess = file.startAccessingSecurityScopedResource()
                appIntent.handleImport(file: file)
                if didStartAccess {
                    file.stopAccessingSecurityScopedResource()
                }
            case .failure(let error):
                appIntent.errorMessage = error.localizedDescription
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .url:
                URLImportSheet(appIntent: appIntent)
            case .text:
                TextImportSheet(appIntent: appIntent)
            }
        }
        .alert("Import", isPresented: Binding(
            get: { appIntent.errorMessage != nil },
            set: { if !$0 { appIntent.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { appIntent.errorMessage = nil }
        } message: {
            Text(appIntent.errorMessage ?? "")
        }
    }
}

private enum ImportSheet: String, Identifiable {
    case url
    case text
    var id: String { rawValue }
}

private struct URLImportSheet: View {
    @ObservedObject var appIntent: AppIntent
    @Environment(\.dismiss) private var dismiss
    @State private var address = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Link to a text file") {
                    TextField("https://example.com/words.txt", text: $address)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Button("Import words") {
                    Task {
                        await appIntent.importFromURL(address)
                        if appIntent.errorMessage == nil { dismiss() }
                    }
                }
                .disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appIntent.isLoading)
            }
            .navigationTitle("Import from URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct TextImportSheet: View {
    @ObservedObject var appIntent: AppIntent
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text("One pair per line, for example: hello — привет")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextEditor(text: $text)
                    .font(.body.monospaced())
                    .frame(minHeight: 220)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    if let clipboardText = UIPasteboard.general.string {
                        text = clipboardText
                    }
                } label: {
                    Label("Paste from clipboard", systemImage: "doc.on.clipboard")
                }
                .buttonStyle(.bordered)

                Button("Import words") {
                    appIntent.importText(text)
                    if appIntent.errorMessage == nil { dismiss() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Paste word pairs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
