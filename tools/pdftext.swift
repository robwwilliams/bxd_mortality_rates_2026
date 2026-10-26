// pdftext.swift: print the text of a PDF with macOS's own PDFKit, so no PDF tools need installing.
// Run: swift tools/pdftext.swift <file.pdf> [number of pages, default all]

import PDFKit

let url = URL(fileURLWithPath: CommandLine.arguments[1])
guard let doc = PDFDocument(url: url) else { print("cannot open \(url.path)"); exit(1) }
let n = CommandLine.arguments.count > 2 ? Int(CommandLine.arguments[2]) ?? doc.pageCount : doc.pageCount
print("PAGES:", doc.pageCount)
for i in 0..<min(n, doc.pageCount) {
  print("\n=== page \(i + 1)")
  print(doc.page(at: i)?.string ?? "")
}
