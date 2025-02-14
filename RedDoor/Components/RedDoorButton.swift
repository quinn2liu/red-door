////
////  RedDoorButton.swift
////  RedDoor
////
////  Created by Quinn Liu on 1/16/25.
////
//
//import SwiftUI
//
//enum RedDoorButtonType {
//    case primary
//    case secondary
//    case tertiary
//    
//    var buttonColor: Color {
//        switch self {
//        case .primary: return .theme.buttonCTA
//        case .secondary: return .theme.buttonTertiary
//        case .tertiary: return .clear
//        }
//    }
//    
//    var textColor: Color {
//        switch self {
//        case .primary: return .theme.buttonContent
//        case .secondary: return .theme.iconPrimary
//        case .tertiary: return .theme.textSecondary
//        }
//    }
//}
//
//// TODO: ButtonStyle support
//struct RedDoorButton: View {
//    var isButton: Bool = true
//    
//    let type: RedDoorButtonType
//    
//    var leadingIcon: String?
//    var leadingIconColor: Color?
//    
//    let text: String
//    var textColor: Color?
//    
//    var buttonColor: Color?
//    
//    var fullWidth: Bool = false
//    var alignment: Alignment = .center
//    let action: () -> Void
//    
//    var body: some View {
//        if isButton {
//            Button(action: action) {
//                RedDoorButtonView()
//            }
//        } else {
//            RedDoorButtonView()
//        }
//    }
//    
//    @ViewBuilder
//    private func RedDoorButtonView() -> some View {
//        HStack {
//            HStack(spacing: 8) {
//                if let leadingIcon {
//                    Image(leadingIcon)
//                        .icon(color: leadingIconColor ?? type.textColor, size: 16)
//                }
//                
//                Text(text)
//                    .font(type == .tertiary ? .footnote : .callout)
//                    .fontWeight(type == .primary ? .bold : .regular)
//                    .foregroundStyle(textColor ?? type.textColor)
//            }
//            .if(fullWidth) { view in
//                view.frame(maxWidth: .infinity, alignment: alignment)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(type.buttonColor) // why not .background(buttonColor) ?
//        .clipShape(.capsule)
//        .if(type == .tertiary) { view in
//            view
//                .overlay(
//                    Capsule()
//                        .inset(by: 0.5)
//                        .stroke(Color.theme.strokeSecondary, lineWidth: 1)
//                )
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
//
//#Preview {
//    CliqueButton(type: .tertiary, leadingIcon: "search", text: "Button", action: {})
//}
//
//
//#Preview {
//    RedDoorButton()
//}
