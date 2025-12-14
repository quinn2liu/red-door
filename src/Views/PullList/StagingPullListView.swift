//
//  StagingPullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/10/25.
//

import SwiftUI

struct StagingPullListView: View {
    @State private var viewModel: PullListViewModel
    @Environment(NavigationCoordinator.self) private var coordinator: NavigationCoordinator

    @State private var errorMessage: String?

    // MARK: Init

    init(pullList: RDList) {
        viewModel = PullListViewModel(selectedList: pullList)   
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 16) {
            RDListTopBar(
                streetAddress: $viewModel.selectedList.address, 
                trailingIcon: Spacer().frame(24),
                status: viewModel.selectedList.status
            )

            RDListDetails(installDate: viewModel.selectedList.installDate, client: viewModel.selectedList.client)

            RoomList()

            Spacer()

            Footer()
        }
        .frameTop()
        .frameHorizontalPadding()
        .toolbar(.hidden)
        .ignoresSafeArea(.keyboard)
    }

    // MARK: Room List

    @ViewBuilder
    private func RoomList() -> some View {
        VStack(spacing: 12) {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.rooms, id: \.self) { room in
                        StagingRoomListItemView(room: room, parentList: viewModel.selectedList, rooms: viewModel.rooms)
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.refreshRDList()
                }
            }
        }
        .task {
            await viewModel.loadRooms()
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

            Button {
                Task { @MainActor in
                    viewModel.selectedList.status = .planning
                    viewModel.updateSelectedList()
                    coordinator.resetSelectedPath()
                    try? await Task.sleep(for: .milliseconds(500))
                    coordinator.appendToSelectedPath(item: viewModel.selectedList)
                }
            } label: {
                Text("Change to planning")
            }

            Spacer()

            Button {
                Task { // TODO: consider wrapping this in some error-handling function
                    do {
                        let installedlist = try await viewModel.createInstalledFromPull()
                        coordinator.resetSelectedPath()
                        try? await Task.sleep(for: .milliseconds(250))
                        coordinator.setSelectedTab(to:.installedList)
                        try? await Task.sleep(for: .milliseconds(250))
                        coordinator.appendToSelectedPath(item: installedlist)
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
        }
    }
}