//
//  HexColorsExtension.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/19/24.
//

import SwiftUI


extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
    
    func getColorName(from hexCode: String) -> String {
        let hex = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if let rgb = Int(hexColor, radix: 16) {
                let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
                let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
                let b = CGFloat(rgb & 0xFF) / 255.0
                
                // Calculate brightness
                let brightness = (r * 299 + g * 587 + b * 114) / 1000
                
                // Calculate saturation
                let max = max(r, g, b)
                let min = min(r, g, b)
                let saturation = (max == 0) ? 0 : (max - min) / max
                
                // White
                if brightness > 0.9 && saturation < 0.1 {
                    return "White"
                }
                
                // Black
                if brightness < 0.1 {
                    return "Black"
                }
                
                // Grey
                if saturation < 0.1 {
                    return "Grey"
                }
                
                // Colored
                let hue = getHue(r: r, g: g, b: b)
                
                switch hue {
                case 0...30, 331...360:
                    return "Red"
                case 31...50:
                    return "Orange"
                case 51...70:
                    return "Yellow"
                case 71...150:
                    return "Green"
                case 151...210:
                    return "Blue"
                case 211...270:
                    return "Purple"
                case 271...330:
                    return brightness > 0.3 ? "Purple" : "Brown"
                default:
                    return "Unknown"
                }
            }
        }
        
        return "Invalid Hex Code"
    }

    func getHue(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
        let max = max(r, g, b)
        let min = min(r, g, b)
        
        var hue: CGFloat = 0
        
        if max == min {
            hue = 0
        } else if max == r {
            hue = (60 * ((g - b) / (max - min)) + 360).truncatingRemainder(dividingBy: 360)
        } else if max == g {
            hue = (60 * ((b - r) / (max - min)) + 120).truncatingRemainder(dividingBy: 360)
        } else if max == b {
            hue = (60 * ((r - g) / (max - min)) + 240).truncatingRemainder(dividingBy: 360)
        }
        
        return hue
    }

}
