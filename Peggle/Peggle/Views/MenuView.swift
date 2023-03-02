//
//  RootView.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var levels = Levels()
    @StateObject private var renderAdaptor = RenderAdaptor()
    @State private var path: [Page] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(spacing: 20) {
                    Text("Menu")
                        .fontDesign(.monospaced)
                        .font(.system(size: 48))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    StyledMenuButton(path: $path, page: Page.designPage, text: "Design")
                    StyledMenuButton(path: $path, page: Page.selectPage, text: "Play")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .background(Color("dark green"))
                .cornerRadius(20)
                .navigationDestination(for: Page.self) { page in
                    if page == Page.designPage {
                        BoardView(path: $path)
                    } else if page == Page.playPage {
                        GameView(path: $path)
                    } else if page == Page.selectPage {
                        SelectionView(path: $path)
                    }
                }
                .zIndex(10)

                Image("menu")
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
        }
        .environmentObject(levels)
        .environmentObject(renderAdaptor)
    }
}

struct StyledMenuButton: View {
    @Binding var path: [Page]
    var page: Page
    var text: String

    var body: some View {
        Button(action: { path.append(page) }) {
            Text(text)
                .fontDesign(.monospaced)
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(Color("grey"))
        }
        .padding()
        .frame(minWidth: 200)
        .background(Color("skin"))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct Page: Hashable {
    static let designPage = Page(name: "design")
    static let playPage = Page(name: "play")
    static let selectPage = Page(name: "select")
    let name: String
}
