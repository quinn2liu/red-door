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
    @State private var date: Date

    @State private var showAddressSheet: Bool = false

    init(viewModel: Binding<PullListViewModel>) {
        _viewModel = viewModel
        self.editingList = viewModel.wrappedValue.selectedList
        self.date = (try? Date(viewModel.wrappedValue.selectedList.installDate, strategy: .dateTime.year().month().day())) ?? Date()
    }

    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            HStack {
                Text("Address:")
                Text(editingList.address.formattedAddress)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .onTapGesture {
                        showAddressSheet = true
                    }
            }

            DatePicker(
                "Install Date:",
                selection: $date,
                displayedComponents: [.date]
            )

            HStack {
                Text("Client:")
                TextField("", text: $editingList.client)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .frameTop()
        .frameHorizontalPadding()
        .frameVerticalPadding()
        .sheet(isPresented: $showAddressSheet) {
            AddressSheet(selectedAddress: $editingList.address)
        }
    }

    // MARK: Top Bar
    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            Text("Save")
                .foregroundColor(.clear)
        }, header: {
            DragIndicator()
        }, trailingIcon: {
            Button {
                let dateString = date.formatted(.dateTime.year().month().day())
                if dateString != viewModel.selectedList.installDate {
                    viewModel.selectedList.installDate = date.formatted(.dateTime.year().month().day())
                }
                if editingList != viewModel.selectedList {
                    viewModel.selectedList = editingList
                    // viewModel.updateRDList()
                    // TODO: UPDATE RDLIST SHOULD TAKE IN THE EDITED LIST
                }
                
            } label: {
                Text("Save")
            }
        })
    }
}