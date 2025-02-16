//
//  ViewExtensions.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/14/25.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func onHighPriorityTap(action: @escaping () -> Void) -> some View {
        self
            .highPriorityGesture(TapGesture().onEnded({ action() }))
    }
}

// MARK: Frame
extension View {
    func frameTop() -> some View {
        self
            .frame(maxHeight: .infinity, alignment: .top)
    }
    
    func frameHorizontalPadding() -> some View {
        self
            .padding(.horizontal, 16)
    }
    
    func frameVerticalPadding() -> some View {
        self
            .padding(.vertical, 16)
    }
    
    func frame(_ size: CGFloat) -> some View {
        self
            .frame(width: size, height: size)
    }
}
