//
//  OptionsView.swift
//  RedDoor
//
//  Created by Quinn Liu on 12/14/25.
//

import SwiftUI

struct OptionsView: View {
    // MARK: init Variables
    @Environment(NavigationCoordinator.self) var coordinator
    @State private var warehouseViewModel: WarehouseViewModel = WarehouseViewModel()

    @State private var showWarehouseSection: Bool = false

    // Editing Warehouses
    @State private var editingWarehouses: Bool = false
    @State private var showAddressSheet: Bool = false
    @State private var newWarehouse: Warehouse = Warehouse(name: "", address: Address())
    @State private var warehouseName: String = ""
    @State private var showWarehouseNameAlert: Bool = false
    @State private var showWarehouseDeleteAlert: Bool = false
    
    private var warehouseAddressExists: Bool {
        warehouseViewModel.warehouses.contains(where: { $0.address.id == newWarehouse.address.id })
    }

    var body: some View {
        VStack(spacing: 16) {
            TopBar()

            StorageSection()
        }
        .frameTop()
        .frameHorizontalPadding()
        .toolbar(.hidden)
        .task {
            if warehouseViewModel.warehouses.isEmpty {
                await warehouseViewModel.fetchWarehouses()
            }
        }
        .sheet(isPresented: $showAddressSheet) {
            AddressSheet(selectedAddress: $newWarehouse.address, addressId: $newWarehouse.id)
                .onDisappear {
                    if newWarehouse.address.isInitialized() {
                        showWarehouseNameAlert = true
                    }
                }
        }
        .alert(warehouseAddressExists ? "Warehouse with that address already exists." : "Enter Warehouse Name", isPresented: $showWarehouseNameAlert) {
            WarehouseNameAlertContent()
        }
        .alert("Confirm Delete", isPresented: $showWarehouseDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showWarehouseDeleteAlert = false
            }
        } message: {
            Text("Reach out to administrator to delete this storage location permanently.")
        }
    }

    // MARK: Top Bar
    @ViewBuilder
    private func TopBar() -> some View {
        TopAppBar(leadingIcon: {
            Text("Options")
                .font(.system(.title2, design: .default))
                .foregroundColor(.red)
                .bold()
        }, header: {
            EmptyView()
        }, trailingIcon: {
            ProfileImage()
        })
    }

    // MARK: Profile Image
    @ViewBuilder
    private func ProfileImage() -> some View {
        Image(systemName: "person.circle")
            .foregroundColor(.red)
            .font(.system(size: 24))
    }

    // MARK: Warehouse Section
    @ViewBuilder
    private func StorageSection() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("Warehouse Locations")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if showWarehouseSection {
                    Button {
                        editingWarehouses.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.red)
                    }
                }

                Button {
                    withAnimation {
                        showWarehouseSection.toggle()
                        editingWarehouses = false
                    }
                } label: {
                    Image(systemName: showWarehouseSection ? "chevron.up" : "chevron.down")
                        .foregroundColor(.red)
                }
            }
            .padding(8)
            .background(Color(.systemGray5))
            .cornerRadius(6)
            .frame(maxWidth: .infinity)

            if showWarehouseSection {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(warehouseViewModel.warehouses, id: \.self) { warehouse in
                        WarehouseListItem(warehouse: warehouse)
                    }
                }

                if editingWarehouses {
                    Button {
                        newWarehouse = Warehouse(name: "", address: Address())
                        showAddressSheet = true
                    } label: {
                        Text("Add Warehouse")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }


    // MARK: Warehouse Name Alert Content
    
    @ViewBuilder
    private func WarehouseNameAlertContent() -> some View {
        if warehouseAddressExists {
            Button("Cancel", role: .cancel) {
                showWarehouseNameAlert = false
                newWarehouse = Warehouse(name: "", address: Address())
            }
        } else {
            TextField("Warehouse Name", text: $warehouseName)
                .textInputAutocapitalization(.never)

            Button("OK") {
                warehouseViewModel.addWarehouse(warehouse: Warehouse(name: warehouseName, address: newWarehouse.address))
                showWarehouseNameAlert = false
                newWarehouse = Warehouse(name: warehouseName, address: newWarehouse.address)
            }.tint(.blue)

            Button("Cancel", role: .cancel) {
                showWarehouseNameAlert = false
                newWarehouse = Warehouse(name: "", address: Address())
            }
        }
    }

    // MARK: Warehouse List Item

    @ViewBuilder
    private func WarehouseListItem(warehouse: Warehouse) -> some View {
        HStack(spacing: 8) {
            Text(warehouse.name)
                .foregroundColor(.primary)

            (
                Text(warehouse.address.getStreetAddress() ?? "")
                +
                Text(", " + (warehouse.address.getCityStateZipcode() ?? ""))
            )
            .font(.caption)
            .foregroundColor(.secondary)
            

            Spacer()

            if editingWarehouses {
                Button {
                    showWarehouseDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(8)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )

    }
}

#Preview {
    OptionsView()
}