//
//  SmallCTA.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/27/25.
//

import SwiftUI

enum SmallCTAType {
    case `default`
    case destructive
    case outline
    case secondary
    case ghost
    case link

    var buttonColor: Color {
        switch self {
        case .default:
            return Color(.black)
        case .destructive:
            return Color(.red)
        case .outline:
            return Color.clear
        case .secondary:
            return Color(.systemGray5)
        case .ghost:
            return Color.clear
        case .link:
            return Color.clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .default:
            return .white
        case .destructive:
            return .white
        case .outline:
            return Color(red: 0.09, green: 0.09, blue: 0.09)
        case .secondary:
            return Color(red: 0.09, green: 0.09, blue: 0.09)
        case .ghost:
            return Color(red: 0.09, green: 0.09, blue: 0.09)
        case .link:
            return Color(red: 0.09, green: 0.09, blue: 0.09)
        }
    }
    
    var borderColor: Color? {
        switch self {
        case .outline:
            return Color(red: 0.89, green: 0.89, blue: 0.89) // hsl(0 0% 89%)
        default:
            return nil
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outline:
            return 1
        default:
            return 0
        }
    }
}

struct SmallCTA: View {
    var isButton: Bool = true

    let type: SmallCTAType

    var leadingIcon: String?
    var leadingIconColor: Color?

    var text: String = ""
    var textColor: Color?

    var buttonColor: Color?

    var fullWidth: Bool = false
    var alignment: Alignment = .center
    var semibold: Bool = true
    var action: () -> Void = {}

    var body: some View {
        if isButton {
            Button(action: action) {
                SmallCTAView()
            }
        } else {
            SmallCTAView()
        }
    }

    @ViewBuilder
    private func SmallCTAView() -> some View {
        HStack(spacing: 4) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .foregroundStyle(leadingIconColor ?? textColor ?? type.foregroundColor)
                    .font(.caption2)
            }

            if text != "" {
                Text(text)
                    .font(.caption2)
                    .if(semibold) { view in
                        view.fontWeight(.semibold)
                    }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(textColor ?? type.foregroundColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 7)
        .if(fullWidth) { view in
            view.frame(maxWidth: .infinity, alignment: alignment)
        }
        .background(buttonColor ?? type.buttonColor)
        .overlay(
            Capsule()
                .stroke(type.borderColor ?? Color.clear, lineWidth: type.borderWidth)
        )
        .clipShape(.capsule)
    }
}

#Preview {
    VStack(spacing: 12) {
        SmallCTA(type: .default, leadingIcon: "plus", text: "Default", action: {})
        SmallCTA(type: .destructive, leadingIcon: "trash", text: "Destructive", action: {})
        SmallCTA(type: .outline, leadingIcon: "plus", text: "Outline", action: {})
        SmallCTA(type: .secondary, leadingIcon: "plus", text: "Secondary", action: {})
        SmallCTA(type: .ghost, leadingIcon: "plus", text: "Ghost", action: {})
        SmallCTA(type: .secondary, leadingIcon: "plus", text: "Custom Color", buttonColor: .blue, action: {})
        SmallCTA(type: .secondary, leadingIcon: "plus", text: "Full Width", fullWidth: true, action: {})
        SmallCTA(type: .secondary, leadingIcon: "plus", text: "Not Semibold", semibold: false, action: {})
        SmallCTA(type: .secondary, leadingIcon: "checkmark", leadingIconColor: .green, text: "Custom Icon Color", action: {})
    }
    .padding()
}
