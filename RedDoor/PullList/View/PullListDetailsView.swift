//
//  PullListDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct PullListDetailsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PullListViewModel
    @State private var isEditing: Bool = false
    @State private var showSheet: Bool = false

    init(pullList: PullList) {
        self.viewModel = PullListViewModel(selectedPullList: pullList)
    }
    
    @FocusState private var keyboardFocused: Bool
        
    @State private var addressQuery: String = ""
    @State private var date: Date = Date()
    
    @State private var showCreateRoom: Bool = false
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 16) {
            TopBar()
            
            DatePicker(
                "Install Date:",
                selection: $date,
                displayedComponents: [.date]
            )
            
            HStack {
                Text("Client:")
                TextField("", text: $viewModel.selectedPullList.client)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            RoomList()
            
            Spacer()
            
            HStack {
                Button("Delete Pull List") {
                    viewModel.deletePullList()
                    dismiss()
                }
                
                Button("Save Pull List") {
                    viewModel.updatePullList()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            PullListAddItemsSheet(showSheet: $showSheet)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden)
        .frameHorizontalPadding()
    }
    
    // MARK: TopBar
    @ViewBuilder private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            BackButton()
        }, header: {
            if isEditing {
                TextField(viewModel.selectedPullList.id, text: $addressQuery)
                    .onChange(of: addressQuery) { _, newValue in
                        // do the address searching stuff (use a sheet?)
                        let address = Address(fullAddress: newValue)
                        viewModel.selectedPullList.id = address.toUniqueID()
                    }
            } else {
                Text(viewModel.selectedPullList.id)
            }
            
        }, trailingIcon: {
            Button {
                if isEditing {
                    viewModel.updatePullList()
                }
                isEditing.toggle()
            } label: {
                Text(isEditing ? "Save" : "Edit")
                    .foregroundStyle(.red)
                    .fontWeight(isEditing ? .semibold : .regular)
            }
        })
    }
    
    // MARK: RoomList
    @ViewBuilder private func RoomList() -> some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.selectedPullList.roomMetadata, id: \.id) { roomData in
                        RoomMetadataListItemView(roomMetadata: roomData)
                    }
                }
            }
            
            TransparentButton(backgroundColor: .green, foregroundColor: .green, leadingIcon: "square.and.pencil", text: "Add Room", fullWidth: true) {
                showCreateRoom = true
            }
        }
    }
    
}

// MARK: CREATE MOCK DATA
//#Preview {
//    PullListDetailsView()
//}
