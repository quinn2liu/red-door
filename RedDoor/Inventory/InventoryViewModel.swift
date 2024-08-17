//
//  InventoryViewModel.swift
//  RedDoor
//
//  Created by Quinn Liu on 8/6/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

extension InventoryView {
    @Observable
    class ViewModel {
        
        let db = Firestore.firestore()

    }
}
