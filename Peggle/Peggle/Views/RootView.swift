//
//  RootView.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import SwiftUI

struct RootView: View {
    @StateObject private var levels = Levels()
    @StateObject private var renderAdaptor = RenderAdaptor()
    @State private var path: [Mode] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Design") {
                    path.append(Mode.designMode)
                    print("path is \(path)")
                }
                Button("Select") {
                    path.append(Mode.selectMode)
                    print("path is \(path)")
                }
            }
            .navigationDestination(for: Mode.self) { mode in
                if mode == Mode.designMode {
                    BoardView(path: $path)
                } else if mode == Mode.playMode {
                    GameView(path: $path)
                } else if mode == Mode.selectMode {
                    SelectionView(path: $path)
                }
            }
            .foregroundColor(Color.blue)
        }
        .environmentObject(renderAdaptor)
        .environmentObject(levels)
    }
}

struct Mode: Hashable {
    static let designMode = Mode(name: "design")
    static let playMode = Mode(name: "play")
    static let selectMode = Mode(name: "select")
    let name: String
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
