import SwiftUI
import UniformTypeIdentifiers

struct XLSXDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType(filenameExtension: "xlsx") ?? .data] }
    let data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

