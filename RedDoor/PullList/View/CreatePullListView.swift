//
//  CreatePullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct CreatePullListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: PullListViewModel = PullListViewModel()
    
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
                    .padding(6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
            }, trailingIcon: {
                Button {
                    viewModel.updatePullList()
                    dismiss()
                } label: {
                    Text("Save")
                        .fontWeight(.bold)
                }
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
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showCreateRoom) {
            CreateRoomSheet()
                .onAppear {
                    newRoomName = ""
                }
        }
        .toolbar(.hidden)
        .frameHorizontalPadding()
    }
    
    // MARK: Create Room Sheet
    @FocusState var keyboardFocused: Bool
    @State private var newRoomName: String = ""
    @ViewBuilder private func CreateRoomSheet() -> some View {

        VStack(spacing: 16) {
            TextField("Room Name", text: $newRoomName)
                .focused($keyboardFocused)
                .submitLabel(.done)
                .onAppear {
                    keyboardFocused = true
                }
            
            HStack(spacing: 0) {
                Button {
                    showCreateRoom = false
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                }

                Spacer()

                Button {
                    viewModel.createEmptyRoom(newRoomName)
                    dismiss()
                } label: {
                    Text("Add Room")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
        }
        .frameHorizontalPadding()
        .presentationDetents([.fraction(0.1)])
    }
    
}


#Preview {
    CreatePullListView()
}
