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
    
    @FocusState private var keyboardFocused: Bool
        
    @State private var addressQuery: String = ""
    @State private var date: Date = Date()
    
    @State private var showCreateRoom: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            TopAppBar(leadingIcon: {
                BackButton()
            }, header: {
                TextField("Type Address", text: $addressQuery)
                    .onChange(of: addressQuery) { _, newValue in
                        // do the address searching stuff (use a sheet?)
                        let address = Address(fullAddress: newValue)
                        viewModel.selectedPullList.id = address.toUniqueID()
                    }
            }, trailingIcon: {
                Spacer().frame(24)
            })
            
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
            
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack {
                        ForEach(Array(viewModel.selectedPullList.roomContents), id: \.key) { room in
                            RoomListView(roomName: room.key, itemIds: room.value)
                        }
                    }
                }
                
                TransparentButton(backgroundColor: .green, foregroundColor: .green, leadingIcon: "square.and.pencil", text: "Add Room", fullWidth: true) {
                    showCreateRoom = true
                }
            }
            
            Spacer()
            
            HStack {
                
                Button("Add Room") {
                    // do stuff
                }
                
                Button("Save Pull List") {
                    viewModel.updatePullList()
                    dismiss()
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden)
        .frameHorizontalPadding()
    }
}

// MARK: CREATE MOCK DATA
//#Preview {
//    PullListDetailsView()
//}
