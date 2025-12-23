//
//  EditPullListDetailsSheet.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/9/25.
//

import SwiftUI

struct EditPullListDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var viewModel: PullListViewModel
    @State private var editingList: RDList
    @State private var date: Date

    @State private var showAddressSheet: Bool = false
    @State private var showCreateRoom: Bool = false
    @State private var editingRoomId: String? = nil

    @FocusState var keyboardFocused: Bool
    @State private var newRoomName: String = ""
    @State private var existingRoomAlert: Bool = false

    init(viewModel: Binding<PullListViewModel>) {
        _viewModel = viewModel
        self.editingList = viewModel.wrappedValue.selectedList
        self.date = (try? Date(viewModel.wrappedValue.selectedList.installDate, strategy: .dateTime.year().month().day())) ?? Date()
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 12) {
            TopBar()

            DatePicker(
                "Install Date:",
                selection: $date,
                displayedComponents: [.date]
            )

            HStack {
                Text("Client:")
                TextField("", text: $editingList.client)
                    .padding(6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }

            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    Text("Rooms:")
                        .font(.headline)
                        .foregroundColor(.red)

                    Spacer()

                    SmallCTA(type: .red, leadingIcon: "plus", text: "Add Room") {
                        editingRoomId = nil
                        showCreateRoom = true
                    }
                }

                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.rooms, id: \.id) { room in
                            EmptyRoomListItem(room.roomName)
                                .onTapGesture {
                                    editingRoomId = room.id
                                    newRoomName = room.roomName
                                    showCreateRoom = true
                                }
                        }
                    }
                }
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .sheet(isPresented: $showAddressSheet) {
            AddressSheet(selectedAddress: $editingList.address, addressId: $editingList.addressId)
        }
        .sheet(isPresented: $showCreateRoom) {
            CreateEmptyRoomSheet()
                .onAppear {
                    if editingRoomId == nil {
                        newRoomName = ""
                    }
                    keyboardFocused = true
                }
        }
    }

    // MARK: Top Bar
    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            RDButton(variant: .red, size: .icon, leadingIcon: "xmark", iconBold: true, fullWidth: false) {
                dismiss()
            }
            .clipShape(Circle())
        }, header: {
            RDButton(variant: .outline, size: .default, text: editingList.address.isInitialized() ? editingList.address.getStreetAddress() ?? "" : "Enter Address") {
                showAddressSheet = true
            }
        }, trailingIcon: {
            RDButton(variant: .red, size: .icon, leadingIcon: "checkmark", iconBold: true, fullWidth: false) {
                let dateString = date.formatted(.dateTime.year().month().day())
                if dateString != viewModel.selectedList.installDate {
                    viewModel.selectedList.installDate = date.formatted(.dateTime.year().month().day())
                }
                if editingList != viewModel.selectedList {
                    viewModel.selectedList = editingList
                    viewModel.updateSelectedList()
                }
                dismiss()
            }
            .clipShape(Circle())
        })
    }

    // MARK: Create Empty Room Sheet
    @ViewBuilder
    private func CreateEmptyRoomSheet() -> some View {
        VStack(spacing: 16) {
            TextField("Room Name", text: $newRoomName)
                .focused($keyboardFocused)
                .submitLabel(.done)

            HStack(spacing: 0) {
                Button {
                    showCreateRoom = false
                    editingRoomId = nil
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                }

                Spacer()

                Button {
                    if editingRoomId == nil {
                        // Creating a new room
                        existingRoomAlert = !viewModel.createEmptyRoom(newRoomName)
                        if !existingRoomAlert {
                            editingList.roomIds.append(Room.roomNameToId(listId: editingList.id, roomName: newRoomName))
                            showCreateRoom = false
                            editingRoomId = nil
                        }
                    } else {
                        // TODO: Handle editing existing room
                        showCreateRoom = false
                        editingRoomId = nil
                    }
                } label: {
                    Text(editingRoomId == nil ? "Add Room" : "Save")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
        }
        .alert("Room with that name already exists.", isPresented: $existingRoomAlert) {
            Button("Ok", role: .cancel) {}
        }
        .frameTop()
        .padding(24)
        .presentationDetents([.fraction(0.125)])
    }

    // MARK: EmptyRoomListItem
    @ViewBuilder
    private func EmptyRoomListItem(_ roomName: String) -> some View {
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