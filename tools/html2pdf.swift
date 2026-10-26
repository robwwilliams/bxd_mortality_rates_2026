// html2pdf.swift: print an HTML file to a paginated PDF (US letter) with macOS's own WebKit, so no tools need installing.
// Run: swift tools/html2pdf.swift <in.html> <out.pdf>

import AppKit
import WebKit

let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])

class Printer: NSObject, WKNavigationDelegate {
  func webView(_ w: WKWebView, didFinish n: WKNavigation!) {
    let pi = NSPrintInfo.shared.copy() as! NSPrintInfo
    pi.paperSize = NSSize(width: 612, height: 792)
    pi.topMargin = 54; pi.bottomMargin = 54; pi.leftMargin = 54; pi.rightMargin = 54
    pi.horizontalPagination = .fit; pi.verticalPagination = .automatic
    pi.jobDisposition = .save; pi.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = output
    let op = w.printOperation(with: pi)
    op.showsPrintPanel = false; op.showsProgressPanel = false
    op.view?.frame = w.bounds
    op.runModal(for: window, delegate: self, didRun: #selector(done), contextInfo: nil)
  }
  @objc func done() { exit(0) }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 816, height: 1056), styleMask: [.borderless], backing: .buffered, defer: false)
let view = WKWebView(frame: window.contentView!.bounds)
window.contentView!.addSubview(view)
let printer = Printer()
view.navigationDelegate = printer
view.loadFileURL(input, allowingReadAccessTo: input.deletingLastPathComponent())
DispatchQueue.main.asyncAfter(deadline: .now() + 120) { print("timed out"); exit(1) }
app.run()
