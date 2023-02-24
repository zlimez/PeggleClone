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
            
            BallCountView(ballCount: renderAdaptor.numOfBalls)
                .position(x: geo.size.width - 100, y: 60)
        }
    }
}

struct WorldObjectView: View {
    var woVM: WorldObjectVM

    var body: some View {
        Image(woVM.sprite)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: woVM.spriteWidth, height: woVM.spriteHeight)
            .rotationEffect(.radians(woVM.rotation))
            .position(x: woVM.x, y: woVM.y)
            .opacity(woVM.spriteOpacity)
    }
}

struct BallCountView: View {
    var ballCount: Int

    var body: some View {
        Text("Balls left: " + String(ballCount))
            .font(.title)
    }
}
