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
    @Binding var path: [Mode]

    var body: some View {
        print("At select view")
        print(levels.levelNames)
        return VStack {
            ForEach(levels.levelNames, id: \.self) { levelName in
                LevelRowView(path: $path, levelName: levelName)
            }
            .navigationTitle("Missions")
        }
    }
}

struct LevelRowView: View {
    @EnvironmentObject var levels: Levels
    @EnvironmentObject var renderAdaptor: RenderAdaptor
    @State private var selectedMode = ModeMapper.codeNames[0]
    @State private var ballGiven = 0
    @Binding var path: [Mode]
    var levelName: String
    
    var body: some View {
        HStack {
            Text(levelName)
            Spacer()
            ModeSelectionView(selectedMode: $selectedMode, ballGiven: $ballGiven)
            NavigationLink(value: Mode.playMode) {
                Button(action: {
                    path.append(Mode.playMode)
                    renderAdaptor.setBoardAndMode(
                        board: levels.levelTable[levelName]!,
                        gameMode: selectedMode,
                        ballCount: ballGiven
                    )
                }) {
                    Image(systemName: "chevron.right")
                }
            }
        }
        .padding(10)
    }
}

struct ModeSelectionView: View {
    @Binding var selectedMode: String
    @Binding var ballGiven: Int

    var body: some View {
        HStack {
            Picker("Game Mode", selection: $selectedMode) {
                ForEach(ModeMapper.codeNames, id: \.self) { mode in
                    Text(mode)
                }
            }
            .frame(width: 300)

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
            Text("Ball Given: \(ballGiven)")
            Button(action: { ballGiven += 1 }) {
                Image(systemName: "plus")
            }
            Button(action: { ballGiven -= 1 }) {
                Image(systemName: "minus")
            }
        }
    }
}
