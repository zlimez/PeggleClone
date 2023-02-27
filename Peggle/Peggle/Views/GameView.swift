//
//  GameView.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var renderAdaptor: RenderAdaptor
    @Binding var path: [Mode]

    var body: some View {
        VStack {
            TopBarView(path: $path)

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
            
            BottomBarView()
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
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

struct TopBarView: View {
    @EnvironmentObject var renderAdapter: RenderAdaptor
    @Binding var path: [Mode]

    var body: some View {
        HStack {
            Button("EXIT") { path.popLast() }
            if let numOfBalls = renderAdapter.numOfBalls {
                BallCountView(ballCount: numOfBalls)
            }

            if let timeLeft = renderAdapter.prettyTimeLeft {
                TimerView(timeLeft: timeLeft)
            }
        }
        .padding(20)
        .background(.white)
    }
}

struct BottomBarView: View {
    @EnvironmentObject var renderAdapter: RenderAdaptor

    var body: some View {
        HStack {
            if let civTally = renderAdapter.civTally {
                CivTallyView(civDeath: civTally.0, allowedDeath: civTally.1)
            }

            Spacer()

            VStack {
                if let targetScore = renderAdapter.targetScore {
                    TargetScoreView(targetScore: targetScore)
                }
                
                if let score = renderAdapter.score {
                    ScoreView(score: score)
                }
            }
        }
        .padding(20)
        .background(.white)
    }
}

struct BallCountView: View {
    var ballCount: Int

    var body: some View {
        Text("Balls left: \(ballCount)")
            .font(.largeTitle)
    }
}

struct ScoreView: View {
    var score: Int

    var body: some View {
        Text("Score: \(score)")
            .font(.largeTitle)
    }
}

struct CivTallyView: View {
    var civDeath: Int
    var allowedDeath: Int
    
    var body: some View {
        Text("Civilian Death: \(civDeath)/\(allowedDeath)")
            .font(.largeTitle)
    }
}

struct TimerView: View {
    var timeLeft: Int
    
    var body: some View {
        Text("Time Left: \(timeLeft)")
            .font(.largeTitle)
    }
}

struct TargetScoreView: View {
    var targetScore: Int
    
    var body: some View {
        Text("Target Score: \(targetScore)")
    }
}
