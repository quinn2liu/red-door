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
    @State private var viewModel: PullListViewModel
    @Binding var path: NavigationPath

    // MARK: View State

    @FocusState private var keyboardFocused: Bool
    @State private var showEditSheet: Bool = false
    @State private var showCreateRoom: Bool = false
    @State private var errorMessage: String?
    @State private var showPDF: Bool = false

    @State private var newRoomName: String = ""
    @State private var existingRoomAlert: Bool = false

    init(pullList: RDList, path: Binding<NavigationPath>) {
        viewModel = PullListViewModel(selectedList: pullList)
        _path = path
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 16) {
            PullListTopBar(
                streetAddress: $viewModel.selectedList.address, 
                trailingIcon: TopBarMenu,
                status: viewModel.selectedList.status
            )

            PullListDetails(installDate: $viewModel.selectedList.installDate, client: $viewModel.selectedList.client)

            RoomList()

            Spacer()

            Footer()
        }
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden)
        .frameTop()
        .frameHorizontalPadding()
        .sheet(isPresented: $showEditSheet) {
            EditPullListDetailsSheet(viewModel: $viewModel)
        }
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

    // MARK: Top Bar Menu

    @ViewBuilder
    private var TopBarMenu: some View {
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

    // MARK: Room List

    @ViewBuilder
    private func RoomList() -> some View {
        VStack(spacing: 12) {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.rooms, id: \.self) { room in
                        RoomPreviewListItemView(room: room)
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.refreshRDList()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadRooms()
            }
        }
    }

    // MARK: Footer

    @ViewBuilder
    private func Footer() -> some View {
        HStack(spacing: 0) {
            Button {
                Task {
                    await viewModel.refreshRDList()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            
            Spacer()

            Button {
                showPDF = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "richtext.page.fill")
                    Text("PDF")
                }
            }

            Spacer()

            Button {
                Task { @MainActor in
                    path = NavigationPath()
                    viewModel.selectedList.status = .staging
                    viewModel.updateSelectedList()
                    try? await Task.sleep(for: .milliseconds(500))
                    path.append(viewModel.selectedList)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chair.lounge.fill")
                    Text("Begin Install")
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
