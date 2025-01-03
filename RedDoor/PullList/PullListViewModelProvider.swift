//
//  PullListViewModel.swift
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
class SharedPullListViewModel {
    
    var selectedPullList: PullList
    
    init(selectedPullList: PullList = PullList()) {
        self.selectedPullList = selectedPullList
    }
    

}

extension PullListView {
    typealias ViewModel = SharedPullListViewModel
}

extension CreatePullListView {
    typealias ViewModel = SharedPullListViewModel
}
