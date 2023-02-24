//
//  GameView.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var renderAdaptor: RenderAdaptor

    var body: some View {
        ZStack {
            GeometryReader { geo in
                generateGameArea(geo)
            }

            ForEach(renderAdaptor.graphicObjects) { woVM in
                WorldObjectView(woVM: woVM)
            }
        }
        .onTapGesture { location in
            renderAdaptor.fireCannonAt(location)
        }
        .ignoresSafeArea()
    }

    func generateGameArea(_ geo: GeometryProxy) -> some View {
        if let activeGameBoard = GameWorld.activeGameBoard {
            if !activeGameBoard.worldBoundsInitialized {
                activeGameBoard.worldBoundsInitialized = true
                DispatchQueue.main.async { renderAdaptor.configScene(geo.size) }
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

struct WorldObjectView: View {
    var woVM: WorldObjectVM

    var body: some View {
        let sprite = woVM.sprite

        return Image(sprite)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: woVM.spriteWidth, height: woVM.spriteHeight)
            .position(x: woVM.x, y: woVM.y)
            .opacity(woVM.spriteOpacity)
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
