//
//  CreatePullListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct CreatePullListView: View {
    
    @Binding var path: NavigationPath

    
    @State private var viewModel: ViewModel = ViewModel()
    @State private var addressQuery: String = ""
    @State var date: Date = Date()
    
    var body: some View {
        VStack {
            Form {
                
                DatePicker(
                    "Install Date:",
                    selection: $date,
                    displayedComponents: [.date]
                )
    //                        let currDate = Date()
    //                        let formatter = DateFormatter()
    //                        self.installdate = formatter.string(from: currDate)
                
                HStack {
                    Text("Client:")
                    TextField("", text: $viewModel.selectedPullList.client)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Section("Rooms:") {
                    ScrollView {
                        LazyVStack {
//                            ForEach(Array(viewModel.selectedPullList.roomContents), id: \.key) { room in
//                                RoomListView(roomName: room.key, items: room.value)
//                            }
                        }
                    }
                }
                
                
            }
            
            HStack {
                
                Button("Add Room") {
                    // do stuff
                }
                
                Button("Save Pull List") {
                    viewModel.createPullList()
                }
            }
        }
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                TextField("Address", text: $addressQuery)
                    .submitLabel(.done)
                    .padding(6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        // do the address searching stuff (use a sheet?)
                        let address = Address(fullAddress: addressQuery)
                        viewModel.selectedPullList.id = address.toUniqueID()
                    }
            }
        }
        .navigationDestination(for: Model.self) { model in
            InstalledListView()
        }
    }
        
}

#Preview {
    @Previewable @State var navPath = NavigationPath()
    CreatePullListView(path: $navPath)
}
