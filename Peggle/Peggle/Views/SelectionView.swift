//
//  SelectionView.swift
//  Peggle
//
//  Created by James Chiu on 1/3/23.
//

import Foundation
import SwiftUI

struct SelectionView: View {
    @EnvironmentObject var levels: Levels
    @Binding var path: [Page]

    var body: some View {
        VStack {
            VStack {
                Text("Missions")
                    .fontWeight(.heavy)
                    .font(.title)
                    .fontDesign(.monospaced)
                ForEach(levels.levelNames, id: \.self) { levelName in
                    LevelRowView(path: $path, levelName: levelName)
                }
            }
            .padding()
            .padding(.top, 25)

            Spacer()
        }
        .onAppear { TrackPlayer.instance.playBGM("risk") }
        .background(Color("dull green").opacity(0.8))
        .ignoresSafeArea()
    }
}

struct LevelRowView: View {
    @EnvironmentObject var levels: Levels
    @EnvironmentObject var renderAdaptor: RenderAdaptor
    @State private var selectedMode = ModeMapper.codeNames[0]
    @State private var ballGiven = 0
    @Binding var path: [Page]
    var levelName: String

    var body: some View {
        HStack {
            Text(levelName)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .fontDesign(.monospaced)
            Spacer()
            ModeSelectionView(selectedMode: $selectedMode, ballGiven: $ballGiven, pickerColor: Color("dark green"))
            Button(action: {
                path.append(Page.playPage)
                renderAdaptor.setBoardAndMode(
                    board: levels.levelTable[levelName]!,
                    gameMode: selectedMode,
                    ballCount: ballGiven
                )
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
        }
        .padding(10)
        .background(Color("dark grey"))
        .cornerRadius(5)
    }
}

struct ModeSelectionView: View {
    @Binding var selectedMode: String
    @Binding var ballGiven: Int
    var pickerColor: Color

    var body: some View {
        HStack {
            Menu {
                Picker("Game Mode", selection: $selectedMode) {
                    ForEach(ModeMapper.codeNames, id: \.self) { mode in
                        Text(mode)
                    }
                }
            } label: {
                Text(selectedMode)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(pickerColor)
                    .cornerRadius(10)
            }

            if let gameMode = ModeMapper.modeToGameAttachmentTable[selectedMode], gameMode.canEditBallCount {
                BallCountEditorView(ballGiven: $ballGiven)
            }
        }
    }
}

struct BallCountEditorView: View {
    @Binding var ballGiven: Int

    var body: some View {
        HStack {
            Text("Balls: \(ballGiven)")
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Button(action: { ballGiven += 1 }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
            }
            .padding(.leading, 15)
            Button(action: { ballGiven -= 1 }) {
                Image(systemName: "minus")
                    .foregroundColor(.white)
            }
        }
        .padding(.leading, 15)
    }
}
