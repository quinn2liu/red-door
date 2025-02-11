//
//  PullListDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct PullListDetailsView: View {
    
    @State var viewModel: ViewModel
    @Binding var path: NavigationPath
    @Binding var isEditing: Bool

    init(path: Binding<NavigationPath>, pullList: PullList, isEditing: Binding<Bool>) {
        self.viewModel = ViewModel(selectedPullList: pullList)
        self._path = path
        self._isEditing = isEditing
    }
    
    var body: some View {
        Text("Address: \(viewModel.selectedPullList.id)")
    }
}

// MARK: CREATE MOCK DATA
//#Preview {
//    PullListDetailsView()
//}
