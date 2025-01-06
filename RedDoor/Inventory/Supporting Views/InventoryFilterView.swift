//
//  InventoryFilterView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/5/25.
//

import Foundation
import SwiftUI

struct InventoryFilterView: View {
    
    @Environment(\.colorScheme) private var scheme
    @Binding var activeType: ModelType?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ModelType.allCases, id: \.rawValue) { type in
                    Button(action: {
                        withAnimation(.snappy) {
                            if (activeType == type) {
                                activeType = nil
                            } else {
                                activeType = type
                            }
                        }
                    }) {
                        Text(type.rawValue)
                            .font(.callout)
                            .foregroundStyle(foregroundColor(for: type))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(backgroundView(for: type))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func foregroundColor(for type: ModelType) -> Color {
        activeType == type ? /*(scheme == .dark ? Color.black : Color.white)*/ Color.white : Color.primary
    }
    
    private func backgroundView(for type: ModelType) -> some View {
        Capsule()
            .fill(activeType == type ? Color.accentColor : Color(.systemGray5))
    }
}
