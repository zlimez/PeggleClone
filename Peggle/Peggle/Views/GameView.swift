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
        VStack(spacing: 0) {
            TopBarView(path: $path)
            ZStack {
                GeometryReader { geo in generateGameArea(geo) }

                if renderAdaptor.viewDimDetermined {
                    ZStack {
                        ForEach(renderAdaptor.graphicObjects) { woVM in
                            WorldObjectView(woVM: woVM)
                        }
                        .zIndex(10)

                        Image("BG")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: renderAdaptor.deviceGameViewSize.width,
                                height: renderAdaptor.deviceGameViewSize.height
                            )
                            .clipped()
                    }
                    .frame(
                        maxWidth: renderAdaptor.deviceGameViewSize.width,
                        maxHeight: renderAdaptor.deviceGameViewSize.height
                    )
                }
            }
            .onTapGesture { location in
                renderAdaptor.fireCannonAt(location)
            }
            .popup(isPresented: $renderAdaptor.gameEnded) {
                GameEndView(score: renderAdaptor.score, endState: renderAdaptor.endState, path: $path)
            }
            BottomBarView()
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }

    func generateGameArea(_ geo: GeometryProxy) -> some View {
        if !renderAdaptor.viewDimDetermined {
            DispatchQueue.main.async { renderAdaptor.configScene(geo.size) }
        }

        return Color.black
            .scaledToFill()
    }
}

struct WorldObjectView: View {
    var woVM: WorldObjectVM

    var body: some View {
        Image(woVM.sprite)
            .resizable()
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
            Button("EXIT") {
                _ = path.popLast()
                // Temp
                GameWorld.activeGameBoard?.exitGame()
            }
            Spacer()
            if let numOfBalls = renderAdapter.numOfBalls {
                BallCountView(ballCount: numOfBalls)
            }
            Spacer()
            if let timeLeft = renderAdapter.prettyTimeLeft {
                TimerView(timeLeft: timeLeft)
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 10)
        .padding(.horizontal, 20)
        .background(.white)
    }
}

struct GameEndView: View {
    var score: Int?
    var endState: String
    @Binding var path: [Mode]

    var body: some View {
        VStack {
            Text("YOU \(endState)")
                .fontWeight(.black)
                .fontDesign(.rounded)
                .font(.largeTitle)

            if let score = score {
                Text("SCORE: \(score)")
                    .fontWeight(.black)
                    .fontDesign(.rounded)
                    .font(.largeTitle)
            }
            Button("EXIT") {
                _ = path.popLast()
                // Temp
                GameWorld.activeGameBoard?.exitGame()
            }
        }
        .padding(40)
        .background(.white)
        .cornerRadius(10)
    }
}

struct BottomBarView: View {
    @EnvironmentObject var renderAdapter: RenderAdaptor

    var body: some View {
        HStack(alignment: .center) {
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
        .frame(height: 75)
        .padding(10)
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
            .font(.largeTitle)
    }
}
