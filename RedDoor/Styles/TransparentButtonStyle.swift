//
//  TransparentButtonStyle.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/20/24.
//

import SwiftUI

struct TransparentButtonStyle: ViewModifier {
    var backgroundColor: Color
    var foregroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
    }
}

extension View {
    func transparentButtonStyle(backgroundColor: Color, foregroundColor: Color) -> some View {
        self.modifier(TransparentButtonStyle(backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
}
