//
//  PDFPreviewUtils.swift
//  RedDoor
//
//  Created by Quinn Liu on 10/6/25.
//

import Foundation
import SwiftUI
import PDFKit

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
                    
                    Spacer()
                } else {
                    PDFKitView(document: pdfDocument!)
                        .border(.gray)
                        .cornerRadius(6)

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

//                    // iOS <17: UIKit share sheet
//                    if #unavailable(iOS 17), let pdfData {
//                        Button("Share / Export PDF") {
//                            presentActivityController(for: pdfData)
//                        }
//                        .padding()
//                    }
                }
            }
        }
        .onAppear() {
            Task {
                await generatePDF()
            }
        }
        .frameTopPadding()
        .frameHorizontalPadding()
        .frameTop()
    }

    // MARK: PDF Generator
    private func generatePDF() async {
        isGeneratingPDF = true
        
        // Fetch all data first before rendering
        var roomsData: [(room: Room, items: [Item], images: [String: UIImage])] = []
        
        for room in rooms {
            let roomViewModel = RoomViewModel(room: room)
            await roomViewModel.getRoomItems()
            await roomViewModel.getRoomModels()
            
            var images: [String: UIImage] = [:]
            
            for item in roomViewModel.items {
                var imageUrl: URL? = nil
                if let itemImage = item.image.imageURL {
                    imageUrl = itemImage
                } else {
                    if let model = roomViewModel.getModelForItem(item) {
                        if let modelImageUrl = model.primaryImage.imageURL {
                            imageUrl = modelImageUrl
                        }
                    }
                }
                
                if let imageUrl = imageUrl,
                   let imageData = try? await URLSession.shared.data(from: imageUrl).0,
                   let image = UIImage(data: imageData) {
                    images[item.id] = image
                }
            }
            
            roomsData.append((room: room, items: roomViewModel.items, images: images))
        }
        
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "RedDoor",
            kCGPDFContextAuthor: "RedDoor App",
            kCGPDFContextTitle: "Pull List - \(pullList.client)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Page size (US Letter: 612 x 792 points)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var yPosition: CGFloat = 40
            let leftMargin: CGFloat = 40
            let rightMargin: CGFloat = 572
            let pageHeight: CGFloat = 752
            
            context.beginPage()
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let title = "Pull List: \(pullList.id)"
            title.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 35
            
            // Pull list info
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14)
            ]
            
            let info = """
            Client: \(pullList.client)
            Install Date: \(pullList.installDate)
            Type: \(pullList.listType)
            """
            
            info.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: infoAttributes)
            yPosition += 70
            
            // Rooms and items
            for roomData in roomsData {
                // Check if we need a new page
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 40
                }
                
                // Room header
                let roomHeaderAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 18)
                ]
                "Room: \(roomData.room.roomName)".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: roomHeaderAttributes)
                yPosition += 30
                
                if !roomData.items.isEmpty {
                    // Table header
                    let tableHeaderAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 12)
                    ]
                    
                    // Draw table header background
                    let headerRect = CGRect(x: leftMargin, y: yPosition, width: rightMargin - leftMargin, height: 25)
                    UIColor.systemGray5.setFill()
                    context.fill(headerRect)
                    
                    "Image".draw(at: CGPoint(x: leftMargin + 5, y: yPosition + 5), withAttributes: tableHeaderAttributes)
                    "Item ID".draw(at: CGPoint(x: leftMargin + 70, y: yPosition + 5), withAttributes: tableHeaderAttributes)
                    "Location".draw(at: CGPoint(x: leftMargin + 200, y: yPosition + 5), withAttributes: tableHeaderAttributes)
                    yPosition += 25
                    
                    // Draw table border
                    UIColor.systemGray3.setStroke()
                    context.stroke(headerRect)
                    
                    // Table rows
                    let cellAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 11)
                    ]
                    
                    for item in roomData.items {
                        // Check if we need a new page
                        if yPosition > pageHeight - 80 {
                            context.beginPage()
                            yPosition = 40
                        }
                        
                        let rowRect = CGRect(x: leftMargin, y: yPosition, width: rightMargin - leftMargin, height: 50)
                        
                        // Draw row border
                        UIColor.systemGray4.setStroke()
                        context.stroke(rowRect)
                        
                        // Draw image if available
                        if let image = roomData.images[item.id] {
                            let imageRect = CGRect(x: leftMargin + 5, y: yPosition + 5, width: 40, height: 40)
                            image.draw(in: imageRect)
                        }
                        
                        // Draw text
                        item.modelId.draw(at: CGPoint(x: leftMargin + 70, y: yPosition + 15), withAttributes: cellAttributes)
                        item.listId.draw(at: CGPoint(x: leftMargin + 200, y: yPosition + 15), withAttributes: cellAttributes)
                        
                        yPosition += 50
                    }
                } else {
                    "No items found".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: infoAttributes)
                    yPosition += 30
                }
                
                yPosition += 20
            }
        }
        
        // Create PDFDocument from data
        pdfDocument = PDFDocument(data: data)
        pdfData = data
        isGeneratingPDF = false
    }

//    // MARK: UIKit share sheet for iOS <17
//    private func presentActivityController(for data: Data) {
//       let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
//       if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//          let root = scene.windows.first?.rootViewController {
//           root.present(activityVC, animated: true)
//       }
//    }
}

// MARK: - PDFKit View Wrapper
struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

// MARK: - PDF File Wrapper for ShareLink
@available(iOS 17, *)
struct PDFFile: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { pdf in
            pdf.data
        }
    }
}
