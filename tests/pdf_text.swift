// Print the text layer of a PDF (what an agent reading the PDF gets). macOS only (PDFKit).
import PDFKit
guard CommandLine.arguments.count == 2,
      let doc = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[1])) else {
  FileHandle.standardError.write("usage: swift pdf_text.swift <file.pdf>\n".data(using: .utf8)!)
  exit(1)
}
print(doc.string ?? "")
