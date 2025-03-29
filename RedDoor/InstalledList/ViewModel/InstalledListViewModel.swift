//
//  InstalledListViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import PhotosUI
import SwiftUI
import FirebaseStorage

@Observable
class InstalledListViewModel {
    
    init(selectedInstalledList: RDList, rooms: [Room]) {
        self.selectedInstalledList = selectedInstalledList
        self.rooms = rooms
    }
    var selectedInstalledList: RDList
    var rooms: [Room] = []
    
    let db = Firestore.firestore()
    
}
