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
    @State private var roomsData: [RoomData] = []
    
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
    @MainActor
    private func generatePDF() async {
        isGeneratingPDF = true
        
        // Fetch all data first
        var fetchedRoomsData: [RoomData] = []
        
        for room in rooms {
            let roomViewModel = RoomViewModel(room: room)
            await roomViewModel.getRoomItems()
            await roomViewModel.getRoomModels()
            
            var itemsData: [ItemData] = []
            
            for item in roomViewModel.items {
                var image: Image? = nil
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
                   let uiImage = UIImage(data: imageData) {
                    image = Image(uiImage: uiImage)
                }
                
                itemsData.append(ItemData(
                    id: item.id,
                    modelId: item.modelId,
                    listId: item.listId,
                    image: image
                ))
            }
            
            fetchedRoomsData.append(RoomData(
                roomName: room.roomName,
                items: itemsData
            ))
        }
        
        roomsData = fetchedRoomsData
        
        // Create PDF using ImageRenderer
        let pdfView = PLGeneratedPDFView(
            pullList: pullList,
            roomsData: roomsData
        )
        
        let renderer = ImageRenderer(content: pdfView)
        renderer.proposedSize = .init(width: 612, height: 792) // US Letter size
        
        // Create temporary file URL
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
        
        // Render to PDF
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            
            guard let pdf = CGContext(tempURL as CFURL, mediaBox: &box, nil) else { return }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        // Load PDF
        if let data = try? Data(contentsOf: tempURL) {
            pdfData = data
            pdfDocument = PDFDocument(data: data)
        }
        
        // Clean up temp file
        try? FileManager.default.removeItem(at: tempURL)
        
        isGeneratingPDF = false
    }
}

// MARK: - Data Models
struct RoomData: Identifiable {
    let id = UUID()
    let roomName: String
    let items: [ItemData]
}

struct ItemData: Identifiable {
    let id: String
    let modelId: String
    let listId: String
    let image: Image?
}

// MARK: - PDF Document View
struct PLGeneratedPDFView: View {
    let pullList: RDList
    let roomsData: [RoomData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Section
            VStack(alignment: .leading, spacing: 4) {
                Text("Pull List: \(pullList.id)")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 6)
                
                Text("Client: \(pullList.client)")
                    .font(.system(size: 14))
                Text("Install Date: \(pullList.installDate)")
                    .font(.system(size: 14))
                Text("Type: \(pullList.listType)")
                    .font(.system(size: 14))
            }
            .padding(.top, 40)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            // Rooms Section
            VStack(alignment: .leading, spacing: 20) {
                ForEach(roomsData) { roomData in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Room: \(roomData.roomName)")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 40)
                        
                        if !roomData.items.isEmpty {
                            // Table with proper borders
                            VStack(spacing: 0) {
                                // Table Header
                                HStack(spacing: 0) {
                                    Text("Image")
                                        .font(.system(size: 12, weight: .bold))
                                        .frame(width: 60, alignment: .leading)
                                        .padding(.leading, 8)
                                    
                                    Text("Item ID")
                                        .font(.system(size: 12, weight: .bold))
                                        .frame(width: 180, alignment: .leading)
                                        .padding(.leading, 8)
                                    
                                    Text("Location")
                                        .font(.system(size: 12, weight: .bold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                                }
                                .frame(height: 25)
                                .background(Color(white: 0.9))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color(white: 0.7), lineWidth: 1)
                                )
                                
                                // Table Rows
                                ForEach(roomData.items) { item in
                                    HStack(spacing: 0) {
                                        // Image cell
                                        Group {
                                            if let image = item.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            } else {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 40, height: 40)
                                            }
                                        }
                                        .frame(width: 60, alignment: .center)
                                        .padding(.leading, 10)
                                        
                                        // Model ID cell
                                        Text(item.modelId)
                                            .font(.system(size: 11))
                                            .frame(width: 180, alignment: .leading)
                                            .padding(.leading, 8)
                                        
                                        // Location cell
                                        Text(item.listId)
                                            .font(.system(size: 11))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 8)
                                    }
                                    .frame(height: 50)
                                    .background(Color.white)
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color(white: 0.8), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 40)
                        } else {
                            Text("No items found")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 40)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: 612, height: 792)
        .background(Color.white)
    }
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
