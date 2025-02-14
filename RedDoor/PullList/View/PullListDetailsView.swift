//
//  PullListDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct PullListDetailsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: PullListViewModel
    @State var isEditing: Bool = false

    init(pullList: PullList) {
        self.viewModel = PullListViewModel(selectedPullList: pullList)
    }
    
    var body: some View {
        Text("Address: \(viewModel.selectedPullList.id)")
        Button {
            viewModel.deletePullList()
            dismiss()
        } label: {
            Text("Delete Pull List")
        }
    }
}

// MARK: CREATE MOCK DATA
//#Preview {
//    PullListDetailsView()
//}
