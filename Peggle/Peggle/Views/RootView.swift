//
//  RootView.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import SwiftUI

struct RootView: View {
    @StateObject private var levels = Levels()

    var body: some View {
        NavigationStack {
            NavigationLink {
                BoardView()
                    .environmentObject(levels)
            } label: {
                Text("Design")
                    .foregroundColor(Color.blue)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
