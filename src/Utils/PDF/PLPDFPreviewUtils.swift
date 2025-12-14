//
//  PDFPreviewUtils.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/6/25.
//

import Foundation
import PDFKit
import SwiftUI

// MARK: - Sample SwiftUI View

struct PullListPDFView: View {
    // MARK: view variables

    @Environment(\.dismiss) private var dismiss
    @State private var pdfDocument: PDFDocument? = nil
    @State private var isGeneratingPDF: Bool = false
    @State private var pdfData: Data? = nil

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
                if pdfDocument == nil {
                    Spacer()

                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Generating PDF")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Spacer()
                } else {
                    PDFKitView(document: pdfDocument!)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1)
                        )

                    if isGeneratingPDF {
                        ProgressView("Preparing PDF for export...")
                            .padding()
                    }

                    // iOS 17+ ShareLink
                    if #available(iOS 17, *), let pdfData {
                        ShareLink(
                            item: PDFFile(data: pdfData),
                            preview: SharePreview(
                                "PullList.pdf",
                                image: Image(systemName: "doc.fill")
                            )
                        ) {
                            Label("Share / Export PDF", systemImage: "square.and.arrow.up")
                        }
                        .padding()
                    }
                }
            }
        }
        .task {
            await generatePDF()
        }
        .frameTopPadding()
        .frameHorizontalPadding()
        .frameTop()
    }

    // MARK: PDF Generator

    @MainActor
    private func generatePDF() async {
        isGeneratingPDF = true

        // Ensure all RoomViewModels are ready
        var roomViewModels: [RoomViewModel] = []

        for room in rooms {
            let roomVM = RoomViewModel(room: room)
            await roomVM.getRoomItems()
            await roomVM.getRoomModels() // TODO: good place for model and item store
            roomViewModels.append(roomVM)
        }

        let preloadedImages: [String: UIImage] = await preloadImages(for: roomViewModels)

        // Create PDF using ImageRenderer
        let pdfView = PLGeneratedPDFView(
            pullList: pullList,
            roomViewModels: roomViewModels,
            preloadedImages: preloadedImages
        )

        let renderer = ImageRenderer(content: pdfView)
        renderer.proposedSize = .init(width: 612, height: 792) // US Letter

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".pdf")

        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(tempURL as CFURL, mediaBox: &box, nil) else { return }

            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }

        if let data = try? Data(contentsOf: tempURL) {
            pdfData = data
            pdfDocument = PDFDocument(data: data)
        }

        try? FileManager.default.removeItem(at: tempURL)

        isGeneratingPDF = false
    }
}

// MARK: - Preload Images

func preloadImages(for rooms: [RoomViewModel]) async -> [String: UIImage] {
    var result: [String: UIImage] = [:]

    for room in rooms {
        for item in room.items {
            if let url = item.image.imageExists ? item.image.imageURL : room.modelsById[item.modelId]?.primaryImage.imageURL {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        result[item.id] = image
                    }
                } catch {
                    print("Failed to preload image for item \(item.id): \(error)")
                }
            }
        }
    }
    return result
}

// MARK: - PDFKit View Wrapper

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context _: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.layer.cornerRadius = 12
        pdfView.layer.masksToBounds = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context _: Context) {
        uiView.document = document
    }
}

// MARK: - PDF File Wrapper for ShareLink

struct PDFFile: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { pdf in
            pdf.data
        }
    }
}
