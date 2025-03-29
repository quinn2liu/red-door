//
//  SmallCTA.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/27/25.
//

import SwiftUI

enum SmallCTAType {
    case primary
    case secondary
    case tertiary
    
    var buttonColor: Color {
        switch self {
        case .primary:
            return .red
        case .secondary, .tertiary:
            return Color(.systemGray6)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary:
            return .primary
        case .secondary:
            return .primary
        case .tertiary:
            return .secondary}
    }
}

struct SmallCTA: View {
    let type: SmallCTAType
    var leadingIcon: String?
    var text: String = ""
    var textColor: Color?
    var buttonColor: Color?
    var action: () -> Void = { }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .foregroundStyle(textColor ?? type.foregroundColor)
                        .frame(12)
                }
                
                if text != "" {
                    Text(text)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(textColor ?? type.foregroundColor)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 5)
            .padding(.bottom, 4)
            .background(buttonColor ?? type.buttonColor)
            .clipShape(.capsule)
        }
    }
}

#Preview {
    SmallCTA(type: .secondary, leadingIcon: "plus", text: "Add", action: {})
}
