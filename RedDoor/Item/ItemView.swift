//
//  ItemView.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/13/24.
//

import SwiftUI

struct ItemView: View {
    @State private var viewModel = ViewModel()
    @State var mode: EditMode
    @State var isAdding: Bool
        
    var body: some View {
        NavigationStack {
            Form {
                Text("hello")
            }
            .navigationTitle(mode == .active ? "Editing \(viewModel.testModel.model_id)" : "Viewing \(viewModel.testModel.model_id)")
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $mode)
        }
    }
}

#Preview {
    ItemView(mode: .active, isAdding: false)
}
