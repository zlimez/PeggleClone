//
//  GameView.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var renderAdaptor: RenderAdaptor
    @Binding var path: [Page]

    var body: some View {
        VStack(spacing: 0) {
            TopBarView(path: $path)
                .zIndex(100)

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
                    .onTapGesture { location in
                        renderAdaptor.fireCannonAt(location)
                    }
                }
            }
            .popup(isPresented: $renderAdaptor.gameEnded) {
                GameEndView(score: renderAdaptor.score, endState: renderAdaptor.endState, path: $path)
            }

            BottomBarView()
        }
        .onAppear { TrackPlayer.instance.playBGM("catch-it") }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
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
    @Binding var path: [Page]

    var body: some View {
        HStack {
            ActionButtonView(text: "MENU") {
                renderAdapter.exitGame()
                path.removeAll()
            }
            Spacer()
            if let timeLeft = renderAdapter.prettyTimeLeft {
                TimerView(timeLeft: timeLeft)
            }
            Spacer()
            if let numOfBalls = renderAdapter.numOfBalls {
                BallCountView(ballCount: numOfBalls)
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 15)
        .padding(.horizontal, 20)
        .background(Color("dark grey"))
    }
}

struct GameEndView: View {
    var score: Int?
    var endState: String
    @Binding var path: [Page]
    @EnvironmentObject var renderAdaptor: RenderAdaptor

    var body: some View {
        VStack {
            Text("YOU \(endState)")
                .fontWeight(.black)
                .fontDesign(.monospaced)
                .font(.largeTitle)
                .padding(.bottom, 5)

            if let score = score {
                Text("SCORE: \(score)")
                    .fontWeight(.black)
                    .fontDesign(.monospaced)
                    .font(.largeTitle)
            }

            HStack(spacing: 30) {
                ActionButtonView(text: "BACK", color: Color("dark green")) {
                    _ = path.popLast()
                }
                ActionButtonView(text: "MENU", color: Color("dark green")) {
                    path.removeAll()
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .background(Color("yellow"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
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

            VStack(alignment: .leading, spacing: 10) {
                if let targetScore = renderAdapter.targetScore {
                    TargetScoreView(targetScore: targetScore)
                }

                if let score = renderAdapter.score {
                    ScoreView(score: score)
                }
            }
            .padding()
            .background(Color("grey"))
            .cornerRadius(10)
        }
        .padding(20)
        .background(Color("dark grey"))
    }
}

struct BallCountView: View {
    var ballCount: Int

    var body: some View {
        HStack {
            Image("volleyball")
                .resizable()
                .frame(width: 30, height: 30)

            Text("\(ballCount)")
                .font(.title3)
                .fontDesign(.monospaced)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct ScoreView: View {
    var score: Int

    var body: some View {
        Text("Score: \(score)")
            .font(.title3)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}

struct CivTallyView: View {
    var civDeath: Int
    var allowedDeath: Int

    var body: some View {
        HStack {
            Image("death")
                .resizable()
                .frame(width: 60, height: 60)
            Text("\(civDeath)/\(allowedDeath)")
                .font(.title3)
                .fontDesign(.monospaced)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct TimerView: View {
    var timeLeft: Int

    var body: some View {
        HStack {
            Image(systemName: "timer")
                .resizable()
                .frame(width: 20, height: 20)

            Text("\(timeLeft)")
                .font(.title3)
                .fontDesign(.monospaced)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red, lineWidth: 3)
        )
        .foregroundColor(.white)
    }
}

struct TargetScoreView: View {
    var targetScore: Int

    var body: some View {
        Text("Target Score: \(targetScore)")
            .font(.title3)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}
