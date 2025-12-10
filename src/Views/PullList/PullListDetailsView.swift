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
    @State private var showEditSheet: Bool = false
    @State private var showCreateRoom: Bool = false
    @State private var errorMessage: String?
    @State private var showPDF: Bool = false
    @State private var newRoomName: String = ""
    @State private var existingRoomAlert: Bool = false
    
    @State private var viewModel: PullListViewModel

    init(pullList: RDList, path: Binding<NavigationPath>) {
        viewModel = PullListViewModel(selectedList: pullList)
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
        .sheet(isPresented: $showEditSheet) {
            EditPullListDetailsSheet(viewModel: $viewModel)
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
            }
        )
        .alert("Room with that name already exists.", isPresented: $existingRoomAlert) {
            Button("Ok", role: .cancel) {}
        }
        .sheet(isPresented: $showCreateRoom) {
            CreateEmptyRoomSheet()
                .onAppear {
                    newRoomName = ""
                    keyboardFocused = true
                }
        }
    }

    // MARK: Top Bar

    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(
            leadingIcon: { BackButton() }, 
            header: {
                Text(viewModel.selectedList.address.formattedAddress)
            }, 
            trailingIcon: {
                Menu {
                    Button("Add Room", systemImage: "plus") {
                        showCreateRoom = true
                    }

                    Button("Edit List Details", systemImage: "pencil") {
                        showEditSheet = true
                    }

                    Button("Delete Pull List", systemImage: "trash") {
                        Task {
                            await viewModel.deleteRDList()
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        )
    }

    // MARK: Pull List Details

    @ViewBuilder
    private func PullListDetails() -> some View {
        VStack(spacing: 12) {
            Text("Install Date: \(viewModel.selectedList.installDate)")
            Text("Client: \(viewModel.selectedList.client)")
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
        }
    }

    // MARK: Footer

    @ViewBuilder
    private func Footer() -> some View {
        HStack(spacing: 12) {
            Button("Show PDF") {
                showPDF = true
            }

            Button {
                Task { // TODO: consider wrapping this in some error-handling function
                    do {
                        let installedlist = try await viewModel.createInstalledFromPull()
                        path.append(installedlist)
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
                    await viewModel.refreshRDList()
                }
            }
        }
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
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                }

                Spacer()

                Button {
                    existingRoomAlert = !viewModel.createEmptyRoom(newRoomName)
                    print("selectedList.roomIds: \(viewModel.selectedList.roomIds)")
                    if !existingRoomAlert { showCreateRoom = false }
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
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .presentationDetents([.fraction(0.125)])
    }
}
