//
//  InstalledListDetailView.swift
//  RedDoor
//
//  Created by Quinn Liu on 3/27/25.
//

import SwiftUI

struct InstalledListDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RDListViewModel
    @Binding var path: NavigationPath
    
    init(installedList: RDList, path: Binding<NavigationPath>) {
        self.viewModel = RDListViewModel(selectedList: installedList)
        self._path = path
    }
    
    @FocusState private var keyboardFocused: Bool
    @State private var isEditing: Bool = false
    @State private var showSheet: Bool = false
    @State private var showCreateRoom: Bool = false
    
    @State private var address: String = ""
    @State private var date: Date = Date()
    
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
    
    // MARK: TopBar()
    @ViewBuilder private func TopBar() -> some View {
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
            if isEditing { // TODO: address searching should be a sheet
                TextField(viewModel.selectedList.address.formattedAddress, text: $address)
                    .onChange(of: address) { _, newValue in
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
    
    // MARK: InstalledListDetails()
    @ViewBuilder private func InstalledListDetails() -> some View {
        
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
    @ViewBuilder private func RoomList() -> some View {
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
    
    @ViewBuilder private func Footer() -> some View {
        if isEditing {
            HStack {
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
//            Button {
//                // turn into installed list
//            } label: {
//                RedDoorButton(type: .green, text: "Create Installed List") {
//                    Task {
//                        let installedList = await viewModel.createInstalledFromPull()
////                        path.append(installedList)
//                    }
//                }
//            }
        }
    }
}

//#Preview {
//    InstalledListDetailView()
//}
