//
//  ControlPanelView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI

struct ControlPanelView: View {
    @EnvironmentObject var levels: Levels
    @State private var levelName = ""
    @Binding var boardViewModel: BoardViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                /// Assumes palette is static upon loaded
                ForEach(Array(BoardViewModel.palette.enumerated()), id: \.offset) { _, pegVariant in
                    PegButtonView(
                        pegVariant: pegVariant.pegColor,
                        action: { boardViewModel.switchToAddPeg(pegVariant) },
                        diameter: pegVariant.pegRadius * 2)
                    .opacity(boardViewModel.selectedAction == Action.add && boardViewModel.selectedPegVariant == pegVariant ? 1 : 0.5)
                }
                Spacer()
                PegButtonView(pegVariant: "delete", action: {
                    boardViewModel.switchToDeletePeg()
                }, diameter: 60)
                .opacity(boardViewModel.selectedAction == Action.delete ? 1 : 0.5)
            }
            .padding([.leading, .trailing], 20)
            HStack {
                Button("LOAD", action: {
                    if let loadedBoard = levels.loadLevel(levelName) {
                        boardViewModel = BoardViewModel(board: loadedBoard)
                    }
                })
                Button("SAVE", action: {
                    levels.saveLevel(levelName: levelName, updatedBoard: boardViewModel.board)
                })
                Button("RESET", action: {
                    boardViewModel.removeAllPegs()
                })
                TextField("Level Name", text: $levelName)
                    .border(.gray)
                    .textFieldStyle(.roundedBorder)
                Button("START", action: {})
            }
            .padding([.leading, .trailing], 20)
        }
        .padding([.top, .bottom], 20)
    }
}

struct PegButtonView: View {
    let pegVariant: String
    let action: () -> Void
    let diameter: CGFloat
    var body: some View {
        Button(action: action) {
            Image(pegVariant)
                .resizable()
                .frame(width: diameter, height: diameter)
        }
    }
}
