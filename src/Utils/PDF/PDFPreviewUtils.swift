//
//  PDFPreviewUtils.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/6/25.
//

import Foundation
import SwiftUI
import WebKit
import PDFKit

// MARK: - Sample SwiftUI View
struct PullListPDFView: View {
    
    // MARK: view variables
    @Environment(\.dismiss) private var dismiss
    @State private var htmlContent: String = ""
    @State private var generatingHTML: Bool = false
    @State private var pdfData: Data? = nil
    @State private var isGeneratingPDF: Bool = false
    @State private var displayWebView: WKWebView?
    
    // MARK: Init variables
    var pullList: RDList
    var rooms: [Room]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.red)
            }
            
            VStack(alignment: .center, spacing: 0) {
                if htmlContent.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Generating PDF")
                    }
                    
                    Spacer()
                } else {
                    HTMLPreview(htmlContent: htmlContent, webViewReference: $displayWebView)
                        .border(.gray)
                        .cornerRadius(6)

                    Button("Export as PDF") {
                        exportPDF()
                    }
                    .padding()
                    .disabled(isGeneratingPDF || displayWebView == nil)
                    
                    if isGeneratingPDF {
                        ProgressView("Generating PDF...")
                            .padding()
                    }
                    
                    // iOS 17+ ShareLink
                    if #available(iOS 17, *), let pdfData {
                        ShareLink(
                            item: PDFFile(data: pdfData, filename: "\(pullList.id).pdf"),
                            preview: SharePreview(
                                "\(pullList.id).pdf",
                                image: Image(systemName: "doc.fill")
                            )
                        ) {
                            Label("Share / Export PDF", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                htmlContent = await generateHTML()
            }
        }
        .frameTopPadding()
        .frameHorizontalPadding()
        .frameTop()
    }

    // MARK: HTML Generator
    private func generateHTML() async -> String {
        generatingHTML = true
        
        var html = """
        <html>
        <head>
        <style>
            body { font-family: -apple-system; padding: 20px; }
            h1 { font-size: 24px; margin-bottom: 10px; }
            h2 { font-size: 20px; margin-top: 20px; }
            table { width: 100%; border-collapse: collapse; margin-top: 10px; }
            th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
            img { max-width: 50px; max-height: 50px; }
        </style>
        </head>
        <body>
        """

        // Pull list info
        html += """
        <h1>Pull List: \(pullList.id)</h1>
        <p>Client: \(pullList.client)</p>
        <p>Install Date: \(pullList.installDate)</p>
        <p>Type: \(pullList.listType)</p>
        """

        // Rooms and items
        for room in rooms {
            let roomViewModel = RoomViewModel(room: room)
            html += "<h2>Room: \(room.roomName)</h2>"
            html += "<table><tr><th>Image</th><th>ItemID</th><th>Location</th></tr>"
            await roomViewModel.getRoomItems()
            if !roomViewModel.items.isEmpty {
                for item in roomViewModel.items {
                    var imageUrl: URL? = nil
                    if let itemImage = item.image.imageURL {
                        imageUrl = itemImage
                    } else {
                        await roomViewModel.getRoomModels()
                        if let model = roomViewModel.getModelForItem(item) {
                            if let modelImageUrl = model.primaryImage.imageURL {
                                imageUrl = modelImageUrl
                            }
                        }
                    }
                    html += """
                    <tr>
                        <td><img src="\(imageUrl?.absoluteString ?? "")" /></td>
                        <td>\(item.modelId)</td>
                        <td>\(item.listId)</td>
                    </tr>
                    """
                }
            } else {
                html += "<tr><td colspan='3'>No items found</td></tr>"
            }
            html += "</table>"
        }

        html += "</body></html>"
        generatingHTML = false
        return html
    }

    // MARK: PDF Export
    private func exportPDF() {
        guard let webView = displayWebView else {
            print("🔴 No WebView available")
            return
        }
        
        isGeneratingPDF = true
        print("🔵 Starting PDF generation")

        // Wait for all images and content to finish rendering
        webView.evaluateJavaScript("""
            new Promise((resolve) => {
                const images = Array.from(document.images);
                if (images.length === 0) { resolve(true); return; }
                let loaded = 0;
                images.forEach(img => {
                    if (img.complete) loaded++;
                    else img.onload = img.onerror = () => { loaded++; if (loaded === images.length) resolve(true); };
                });
                if (loaded === images.length) resolve(true);
            });
        """) { _, _ in
            webView.createPDF { data in
                print("🟢 PDF generation completed, data size: \(data?.count ?? 0) bytes")
                self.pdfData = data
                self.isGeneratingPDF = false
            }
        }
    }
}

// MARK: - HTML WebView Wrapper
struct HTMLPreview: UIViewRepresentable {
    let htmlContent: String
    @Binding var webViewReference: WKWebView?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(htmlContent, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLPreview
        init(parent: HTMLPreview) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.webViewReference = webView
            }
        }
    }
}

// MARK: - PDF File Wrapper for ShareLink
struct PDFFile: Transferable {
    let data: Data
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf, exporting: { pdf in pdf.data })
            .suggestedFileName { pdf in pdf.filename }
    }
}

// MARK: - PDF Generation from WebView
extension WKWebView {
    func createPDF(completion: @escaping (Data?) -> Void) {
        let config = WKPDFConfiguration()
        config.rect = .zero // capture full content

        self.createPDF(configuration: config) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print("PDF generation failed:", error)
                completion(nil)
            }
        }
    }
}
