//
//  InstalledListDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/27/25.
//

import SwiftUI

struct InstalledListDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: InstalledListViewModel
    @Binding var path: NavigationPath

    init(installedList: RDList, path: Binding<NavigationPath>) {
        viewModel = InstalledListViewModel(selectedList: installedList)
        _path = path
    }

    @FocusState private var keyboardFocused: Bool
    @State private var isEditing: Bool = false
    @State private var showSheet: Bool = false
    @State private var showCreateRoom: Bool = false

    @State private var address: String = ""
    @State private var date: Date = .init()

    // MARK: Body
    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            InstalledListDetails()

            RoomList()

            Spacer()

            Footer()
        }
        .onAppear {
            Task {
                await viewModel.loadRooms()
            }
        }
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden)
        .frameHorizontalPadding()
    }

    // MARK: Top Bar

    @ViewBuilder 
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            if isEditing {
                Button {
                    isEditing = false
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.blue)
                }
            } else {
                BackButton(path: $path)
            }
        }, header: {
            if isEditing {
                TextField(viewModel.selectedList.address.formattedAddress, text: $address)
                    .onChange(of: address) { _, _ in
                        viewModel.selectedList.id = address
                    }
            } else {
                Text(viewModel.selectedList.address.formattedAddress)
            }

        }, trailingIcon: {
            Button {
                if isEditing {
                    let dateString = date.formatted(.dateTime.year().month().day())
                    if dateString != viewModel.selectedList.installDate {
                        viewModel.selectedList.installDate = date.formatted(.dateTime.year().month().day())
                    }
                    viewModel.updateRDList()
                }
                isEditing.toggle()
            } label: {
                Text(isEditing ? "Save" : "Edit")
                    .foregroundStyle(isEditing ? .blue : .red)
                    .fontWeight(isEditing ? .semibold : .regular)
            }
        })
    }

    // MARK: Installed List Details

    @ViewBuilder 
    private func InstalledListDetails() -> some View {
        VStack(spacing: 12) {
            if isEditing {
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
            } else {
                Text("Install Date: \(viewModel.selectedList.installDate)")
                Text("Client: \(viewModel.selectedList.client)")
            }
        }
    }

    // MARK: Room List

    @ViewBuilder 
    private func RoomList() -> some View {
        VStack(spacing: 12) {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.rooms, id: \.self) { room in
                        RoomListItemView(room: room)
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.refreshRDList()
                }
            }

            if isEditing {
                TransparentButton(backgroundColor: .green, foregroundColor: .green, leadingIcon: "square.and.pencil", text: "Add Room", fullWidth: true) {
                    showCreateRoom = true
                }
            }
        }
    }

        // MARK: Footer

    @ViewBuilder 
    private func Footer() -> some View {
        if isEditing {
            HStack {
                Button("Delete Installed List") {
                    Task {
                        await viewModel.deleteRDList()
                        dismiss()
                    }
                }

                Button("Save Installed List") {
                    viewModel.updateRDList()
                    dismiss()
                }

                Button {
                    Task {
                        let pullList = try await viewModel.createPullFromInstalled()
                        path.append(pullList)
                    }
                } label: {
                    Text("Create Pull List")
                }                
            }
        }
    }
}
