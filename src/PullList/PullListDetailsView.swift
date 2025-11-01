//
//  PullListDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

// TODO: make the edit view a sheet (should only be editing the metadata of the pull list)
struct PullListDetailsView: View {
    // MARK: Navigation

    @Environment(\.dismiss) private var dismiss
    @Binding var path: NavigationPath

    // MARK: View State

    @FocusState private var keyboardFocused: Bool
    @State private var isEditing: Bool = false
    @State private var showSheet: Bool = false
    @State private var showCreateRoom: Bool = false
    @State private var errorMessage: String?
    @State private var showPDF: Bool = false

    // MARK: PullListData

    @State private var address: String = ""
    @State private var date: Date = .init()
    @State private var viewModel: RDListViewModel

    init(pullList: RDList, path: Binding<NavigationPath>) {
        viewModel = RDListViewModel(selectedList: pullList)
        _path = path
    }

    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            PullListDetails()

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
        .fullScreenCover(isPresented: $showPDF) {
            PullListPDFView(pullList: viewModel.selectedList, rooms: viewModel.rooms)
        }
        .alert("Pull List Not Valid",
               isPresented: .constant(errorMessage != nil),
               actions: {
                   Button("Close") { errorMessage = nil }
               },
               message: {
                   if let errorMessage = errorMessage {
                       Text(errorMessage)
                   }
               })
    }

    // MARK: TopBar()

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
                BackButton()
            }
        }, header: {
            if isEditing { // TODO: address searching should be a sheet
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
                    viewModel.updatePullList()
                }
                isEditing.toggle()
            } label: {
                Text(isEditing ? "Save" : "Edit")
                    .foregroundStyle(isEditing ? .blue : .red)
                    .fontWeight(isEditing ? .semibold : .regular)
            }
        })
    }

    // MARK: PullListDetails()

    @ViewBuilder
    private func PullListDetails() -> some View {
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

    // MARK: RoomList()

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
                    await viewModel.refreshPullList()
                }
            }

            if isEditing {
                TransparentButton(backgroundColor: .green, foregroundColor: .green, leadingIcon: "square.and.pencil", text: "Add Room", fullWidth: true) {
                    showCreateRoom = true
                }
            }
        }
    }

    // MARK: Footer()

    @ViewBuilder
    private func Footer() -> some View {
        if isEditing {
            HStack(spacing: 12) {
                Button("Delete Pull List") {
                    Task {
                        await viewModel.deletePullList()
                        dismiss()
                    }
                }

                Button("Save Pull List") {
                    viewModel.updatePullList()
                    dismiss()
                }
            }
        } else {
            HStack(spacing: 12) {
                Button("Show PDF") {
                    showPDF = true
                }

                Button {
                    Task { // TODO: consider wrapping this in some error-handling function
                        do {
                            let installedlist = try await viewModel.createInstalledFromPull()
                        } catch let PullListValidationError.itemDoesNotExist(id) {
                            errorMessage = "Item \(id) does not exist."
                        } catch let PullListValidationError.itemNotAvailable(id) {
                            errorMessage = "Item \(id) is not available."
                        } catch let PullListValidationError.modelDoesNotExist(id) {
                            errorMessage = "Model \(id) does not exist."
                        } catch let PullListValidationError.modelAvailableCountInvalid(id) {
                            errorMessage = "Model \(id) has insufficient available items."
                        } catch InstalledFromPullError.creationFailed {
                            errorMessage = "Unable to create Installed list."
                        } catch {
                            errorMessage = "Unexpected error: \(error.localizedDescription)"
                        }
                    }
                } label: {
                    Text("Create Installed List")
                }

                RedDoorButton(type: .blue, text: "Refresh Contents") {
                    Task {
                        await viewModel.refreshPullList()
                    }
                }
            }
        }
    }
}
