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
    
    func frameTopPadding() -> some View {
        self
            .padding(.top, 16)
    }
    
    func frame(_ size: CGFloat) -> some View {
        self
            .frame(width: size, height: size)
    }
    
    func cornerRadius(_ radius: CGFloat) -> some View {
        self
            .clipShape(.rect(cornerRadius: radius))
    }
}

// MARK: UIWindow
extension UIWindow {
    static var current: UIWindow? {
        return MainActor.assumeIsolated {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                for window in windowScene.windows {
                    if window.isKeyWindow { return window }
                }
            }
            return nil
        }
    }
}

// MARK: UIScreen
extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
    
    static var width: CGFloat {
        UIScreen.current?.bounds.width ?? 0
    }
    
    static var height: CGFloat {
        UIScreen.current?.bounds.height ?? 0
    }
}
