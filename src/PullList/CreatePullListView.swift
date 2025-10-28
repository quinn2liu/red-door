//
//  CreatePullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct CreatePullListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: RDListViewModel = RDListViewModel()
    
    @State private var showAddressSheet: Bool = false
    @State private var selectedAddressMode: String = "Search"
    let addressOptions = ["Search", "Entry"]
    @State private var address: String = ""
    @State private var date: Date = Date()
    
    @State private var showCreateRoom: Bool = false
    private var rooms: [Room]?
    
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
                TextField("", text: $viewModel.selectedList.client)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.selectedList.roomIds, id: \.self) { roomId in
                            EmptyRoomListItem(roomId)
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
        .sheet(isPresented: $showAddressSheet) {
            AddressSheet()
        }
    }
    
    // MARK: TopBar
    @ViewBuilder private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            BackButton()
        }, header: {
            if viewModel.selectedList.address.isInitialized() {
                Text(viewModel.selectedList.address.formattedAddress)
            } else {
                Button {
                    showAddressSheet = true
                } label: {
                    Text("Enter Address")
                }
            }
        }, trailingIcon: {
            Button {
                viewModel.selectedList.installDate = date.formatted(.dateTime.year().month().day())
                viewModel.createPullList()
                dismiss()
            } label: {
                Text("Save")
                    .fontWeight(.bold)
            }
        })
    }
    
    @ViewBuilder
    private func AddressSheet() -> some View {
        VStack(alignment: .center, spacing: 12) {
            Capsule()
                .fill(Color(.systemGray3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            Picker("Address Mode", selection: $selectedAddressMode) {
                ForEach(addressOptions, id: \.self) { mode in
                    Text(mode).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            Group {
                if selectedAddressMode == "Search" {
                    AddressSearchView($viewModel.selectedList.address)
                } else {
                    AddressEntryView($viewModel.selectedList.address)
                }
            }
        }
        .frameTop()
        .frameTopPadding()
        .frameHorizontalPadding()
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
    
    // MARK: EmptyRoomListItem()
    @ViewBuilder private func EmptyRoomListItem(_ roomName: String) -> some View {
    
        HStack(spacing: 0) {
            Text(roomName)
                .foregroundStyle(Color(.label))
                    
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}


#Preview {
    CreatePullListView()
}
