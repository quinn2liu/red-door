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
    @State private var htmlContent: String = ""

    // Example: Replace with your actual data
    var pullList: RDList
    var rooms: [Room]

    var body: some View {
        ZStack {
            if !htmlContent.isEmpty {
                HTMLPreview(htmlContent: htmlContent)

                Button("Download as PDF") {
                    exportPDF()
                }
                .padding()
            }
        }
        .onAppear() {
            Task {
                htmlContent = await generateHTML()
            }
        }
        .padding()
    }

    // MARK: HTML Generator
    private func generateHTML() async -> String {
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
        for room in rooms { // TODO: update the items fetching here
            var roomViewModel = RoomViewModel(room: room)
            html += "<h2>Room: \(room.roomName)</h2>"
            html += "<table><tr><th>Item</th><th>Location</th><th>Image</th></tr>"
            await roomViewModel.getRoomItems()
            if !roomViewModel.items.isEmpty {
                for item in roomViewModel.items {
                    var imageUrl = URL(string: "")
                    if let itemImage = item.image.imageURL {
                        imageUrl = itemImage
                    } else if let model = roomViewModel.getModelForItem(item) {
                        if let modelImageUrl = model.primaryImage.imageURL {
                            imageUrl = modelImageUrl
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
                html += """
                <tr>
                    <td>get items error</td>
                </tr>
                """
                html += "</table>"
            }
            
        }

        html += "</body></html>"
        return html
    }

    // MARK: PDF Export
    private func exportPDF() {
        let webView = WKWebView(frame: .zero)
        webView.loadHTMLString(htmlContent, baseURL: nil)
        webView.createPDF { data in
            guard let pdfData = data else { return }
            
            // Example: save to Documents directory
            let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("PullList.pdf")
            do {
                try pdfData.write(to: filename)
                print("PDF saved at: \(filename)")
            } catch {
                print("Failed to save PDF:", error)
            }
        }
    }
}

// MARK: - HTML WebView Wrapper
struct HTMLPreview: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(htmlContent, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

// MARK: - PDF Generation from WebView
extension WKWebView {
    func createPDF(completion: @escaping (Data?) -> Void) {
        let config = WKPDFConfiguration()
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
