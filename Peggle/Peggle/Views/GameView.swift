//
//  GameView.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameBoardVM: GameBoardVM

    var body: some View {
        ZStack {
            GeometryReader { geo in
                generateGameArea(geo)
            }

            ForEach(gameBoardVM.bodyVMs) { bodyVM in
                RigidBodyView(rbVM: bodyVM)
            }
        }
        .onTapGesture { location in
            gameBoardVM.fireCannonAt(location)
        }
        .ignoresSafeArea()
    }

    func generateGameArea(_ geo: GeometryProxy) -> some View {
        if let activeGameBoard = GameWorld.activeGameBoard {
            if !activeGameBoard.worldBoundsInitialized {
                activeGameBoard.worldBoundsInitialized = true
                DispatchQueue.main.async { gameBoardVM.configScene(geo.size) }
            }
        }

        return ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width)

            CannonView()
                .position(x: geo.size.width / 2, y: 60)
        }
    }
}

struct RigidBodyView: View {
    var rbVM: RigidBodyVM

    var body: some View {
        let sprite = rbVM.sprite

        return Image(sprite)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: rbVM.spriteWidth, height: rbVM.spriteHeight)
            .position(x: rbVM.x, y: rbVM.y)
            .opacity(rbVM.spriteOpacity)
    }
}

struct CannonView: View {
    var width: CGFloat = 150
    var body: some View {
        Image("cannon-static")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
    }
}
