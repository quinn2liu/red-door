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

    @State private var showPDFPreview: Bool = false
    @State private var errorMessage: String?

    // MARK: Init

    init(pullList: RDList) {
        viewModel = PullListViewModel(selectedList: pullList)   
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 12) {
            RDListTopBar(
                streetAddress: $viewModel.selectedList.address, 
                trailingIcon: RefreshButton,
                status: viewModel.selectedList.status
            )

            RDListDetails(installDate: viewModel.selectedList.installDate, client: viewModel.selectedList.client)

            HStack(spacing: 0) {
                SmallCTA(type: .secondary, leadingIcon: "arrow.counterclockwise", text: "Set as planning") {
                    Task { @MainActor in
                        viewModel.selectedList.status = .planning
                        viewModel.updateSelectedList()
                        coordinator.resetSelectedPath()
                        try? await Task.sleep(for: .milliseconds(500))
                        coordinator.appendToSelectedPath(viewModel.selectedList)
                    }
                }

                Spacer()

                SmallCTA(type: .secondary, leadingIcon: "richtext.page.fill", text: "Show PDF") {
                    showPDFPreview = true
                }
            }

            RoomList()

            Spacer()

            Footer()
        }
        .frameTop()
        .frameHorizontalPadding()
        .toolbar(.hidden)
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $showPDFPreview) {
            PullListPDFView(pullList: viewModel.selectedList, rooms: viewModel.rooms)
        }
    }

    // MARK: Room List

    @ViewBuilder
    private func RoomList() -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("Rooms:")
                    .font(.headline)
                    .foregroundColor(.red)

                Spacer()
            }

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
        RDButton(variant: .default, size: .default, leadingIcon: "truck.box.badge.clock.fill", text: "Create Installed List", fullWidth: true) {
            Task { // TODO: consider wrapping this in some error-handling function
                do {
                    let installedlist = try await viewModel.createInstalledFromPull()
                    coordinator.resetSelectedPath()
                    try? await Task.sleep(for: .milliseconds(250))
                    coordinator.setSelectedTab(to:.installedList)
                    try? await Task.sleep(for: .milliseconds(250))
                    coordinator.appendToSelectedPath(installedlist)
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
        }
        .padding(.bottom, 12)
    }

    // MARK: Refresh Button

    @ViewBuilder
    private var RefreshButton: some View {
        RDButton(variant: .red, size: .icon, leadingIcon: "arrow.counterclockwise", iconBold: true, fullWidth: false) {
            Task {
                await viewModel.refreshRDList()
            }
        }
        .clipShape(Circle())
    }
}