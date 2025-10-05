//
//  PullListDetailsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

// TODO: make the edit view a sheet (should only be editing the metadata of the pull list)
struct PullListDetailsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RDListViewModel
    @Binding var path: NavigationPath
    
    init(pullList: RDList, path: Binding<NavigationPath>) {
        self.viewModel = RDListViewModel(selectedList: pullList)
        self._path = path
    }
    
    @FocusState private var keyboardFocused: Bool
    @State private var isEditing: Bool = false
    @State private var showSheet: Bool = false
    @State private var showCreateRoom: Bool = false
    
    @State private var addressQuery: String = ""
    @State private var date: Date = Date()
    
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
            if isEditing {
                TextField(viewModel.selectedList.id, text: $addressQuery)
                    .onChange(of: addressQuery) { _, newValue in
                        // do the address searching stuff (use a sheet?)
                        let address = Address(fullAddress: newValue)
                        viewModel.selectedList.id = address.toUniqueID()
                    }
            } else {
                Text(viewModel.selectedList.id)
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
    
    @ViewBuilder
    private func Footer() -> some View {
        if isEditing {
            HStack {
                Button("Delete Pull List") {
                    viewModel.deletePullList()
                    dismiss()
                }
                
                Button("Save Pull List") {
                    viewModel.updatePullList()
                    dismiss()
                }
            }
        } else {
            RedDoorButton(type: .green, text: "Create Installed List") {
                Task {
                    let installedList = await viewModel.createInstalledFromPull()
                    path.append(installedList)
                }
            }
        }
    }
}
// MARK: CREATE MOCK DATA
//#Preview {
//    PullListDetailsView()
//}
