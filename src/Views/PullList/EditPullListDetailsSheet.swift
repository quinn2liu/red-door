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
    @State private var newRoomNames: [String] = []
    @State private var date: Date

    @State private var showAddressSheet: Bool = false
    @State private var showEditRoom: Bool = false

    @FocusState var keyboardFocused: Bool
    @State private var editingRoomName: String = ""
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

            RoomsList()
        }
        .frameTop()
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .sheet(isPresented: $showAddressSheet) {
            AddressSheet(selectedAddress: $editingList.address, addressId: $editingList.addressId)
        }
        .sheet(isPresented: $showEditRoom) {
            EditRoomSheet()
                .onAppear {
                    editingRoomName = ""
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
                    Task {
                        await viewModel.updateSelectedList(newRoomNames: newRoomNames)
                        await viewModel.loadRooms()
                    }
                }
                dismiss()
            }
            .clipShape(Circle())
        })
    }

    // MARK: Rooms List
    @ViewBuilder
    private func RoomsList() -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                Text("Rooms:")
                    .font(.headline)
                    .foregroundColor(.red)

                Spacer()

                SmallCTA(type: .red, leadingIcon: "plus", text: "Add Room") {
                    showEditRoom = true
                    editingRoomName = ""
                }
            }

            ScrollView {
                LazyVStack {
                    ForEach(editingList.roomIds, id: \.self) { roomId in
                        let roomName = roomId.replacingOccurrences(of: "-", with: " ").capitalized
                        RoomListItem(roomName: roomName)
                    }
                }
            }
        }
    }


    // MARK: Create Empty Room Sheet
    @ViewBuilder
    private func EditRoomSheet() -> some View {
        VStack(spacing: 16) {
            TextField("Room Name", text: $editingRoomName)
                .focused($keyboardFocused)
                .submitLabel(.done)

            HStack(spacing: 0) {
                Button {
                    showEditRoom = false
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                }

                Spacer()

                Button {
                    // Creating a new room
                    existingRoomAlert = viewModel.roomExists(newRoomName: editingRoomName, roomIds: editingList.roomIds)
                    if !existingRoomAlert {
                        editingList.roomIds.append(Room.nameToId(roomName: editingRoomName))
                        newRoomNames.append(editingRoomName)
                        showEditRoom = false
                    }
                } label: {
                    Text("Add Room")
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

    // MARK: Room List Item

    @ViewBuilder
    private func RoomListItem(roomName: String) -> some View {
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