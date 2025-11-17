//
//  DeleteButton.swift
//  RedDoor
//
//  Created by Quinn Liu on 4/10/25.
//

import SwiftUI

struct DeleteButton: View {
    var size: CGFloat = 16
    var offset: CGFloat = -8
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill") // X icon
                .foregroundColor(.gray)
                .background(.white)
                .font(.system(size: size))
                .clipShape(Circle())
                .padding(.top, offset)
                .padding(.trailing, offset)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DeleteButton(size: 16) {
        // lol
    }
}
