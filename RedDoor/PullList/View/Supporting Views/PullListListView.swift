//
//  PullListListView.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import SwiftUI

struct PullListListView: View {
    let pullList: RDList
    
    init(_ pullList: RDList) { // Underscore removes the argument label
        self.pullList = pullList
    }
    
    var body: some View {
        Text(pullList.id)
    }
}

// MARK: MAKE MOCK DATA
//#Preview {
//    PullListListView()
//}
