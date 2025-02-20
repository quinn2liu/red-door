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
            
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden)
        .frameHorizontalPadding()
        .sheet(isPresented: $showCreateRoom) {
            CreateEmptyRoomSheet()
                .onAppear {
                    newRoomName = ""
                    keyboardFocused = true
                }
        }
    }
    
    // MARK: TopBar
    @ViewBuilder private func TopBar() -> some View {
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
                viewModel.createPullList()
                dismiss()
            } label: {
                Text("Save")
                    .fontWeight(.bold)
            }
        })
    }
    
    // MARK: Create Empty Room Sheet ()
    @FocusState var keyboardFocused: Bool
    @State private var newRoomName: String = ""
    @State private var existingRoomAlert: Bool = false
    @ViewBuilder private func CreateEmptyRoomSheet() -> some View {

        VStack(spacing: 16) {
            TextField("Room Name", text: $newRoomName)
                .focused($keyboardFocused)
                .submitLabel(.done)
            
            HStack(spacing: 0) {
                Button {
                    showCreateRoom = false
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                }

                Spacer()

                Button {
                    existingRoomAlert = !viewModel.createEmptyRoom(newRoomName)
                    if !existingRoomAlert {
                        showCreateRoom = false
                    }
                } label: {
                    Text("Add Room")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
        }
        .alert("Room with that name already exists.", isPresented: $existingRoomAlert) {
            Button("Ok", role: .cancel) { }
        }
        .frameHorizontalPadding()
        .presentationDetents([.fraction(0.1)])
    }
    
}


#Preview {
    CreatePullListView()
}
