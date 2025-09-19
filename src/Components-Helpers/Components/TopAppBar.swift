//
//  TopAppBar.swift
//  RedDoor
//
//  Created by Quinn Liu on 2/14/25.
//

import SwiftUI

struct TopAppBar<LeadingIcon: View, Header: View, TrailingIcon: View>: View {
    @ViewBuilder var leadingIcon: LeadingIcon
    @ViewBuilder var header: Header
    @ViewBuilder var trailingIcon: TrailingIcon
    
    var body: some View {
        HStack(spacing: 0) {
            leadingIcon
            
            Spacer()
            
            header
            
            Spacer()
            
            trailingIcon
        }
    }
}

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var path: Binding<NavigationPath>? = nil

    var body: some View {
        Button {
            if path != nil {
                print("path reset triggered")
                self.path?.wrappedValue = NavigationPath()
            } else {
                dismiss()
            }
        } label: {
            Image(systemName: "chevron.left")
                .fontWeight(.bold)
                .frame(24)
        }.tint(.red)
    }
}
