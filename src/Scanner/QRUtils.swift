//
//  QRUtils.swift
//  RedDoor
//
//  Created by Quinn Liu on 11/16/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

extension String {
    func generateQRCode() -> UIImage? {
        let context: CIContext = CIContext()
        let filter: any CIFilter & CIQRCodeGenerator = CIFilter.qrCodeGenerator()

        let data: Data = Data(self.utf8)
        filter.message = data
        
        if let outputImage: CIImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    func generateQRCode(scale: CGFloat) -> UIImage? {
        let context: CIContext = CIContext()
        let filter: any CIFilter & CIQRCodeGenerator = CIFilter.qrCodeGenerator()

        let data: Data = Data(self.utf8)
        filter.message = data
        
        if let outputImage: CIImage = filter.outputImage {
            // Scale up the image for higher resolution
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

// MARK: - QR Code Image Wrapper for ShareLink

struct QRCodeImage: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { qrCode in
            qrCode.data
        }
    }
}