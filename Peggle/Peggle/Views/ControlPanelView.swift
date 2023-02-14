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
    @Binding var designBoardVM: DesignBoardVM

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                /// Assumes palette is static upon loaded
                ForEach(Array(DesignBoard.palette.enumerated()), id: \.offset) { _, pegVariant in
                    PegButtonView(
                        pegVariant: pegVariant.pegColor,
                        action: { designBoardVM.switchToAddPeg(pegVariant) },
                        diameter: pegVariant.pegRadius * 2)
                    .opacity(designBoardVM.isVariantActive(pegVariant) ? 1 : 0.5)
                }
                Spacer()
                PegButtonView(pegVariant: "delete", action: {
                    designBoardVM.switchToDeletePeg()
                }, diameter: 60)
                .opacity(designBoardVM.selectedAction == Action.delete ? 1 : 0.5)
            }
            HStack {
                Button("LOAD") {
                    if let loadedBoard = levels.loadLevel(levelName) {
                        designBoardVM = DesignBoardVM(DesignBoard(board: loadedBoard))
                    } else {
                        designBoardVM = DesignBoardVM.getEmptyBoard()
                    }
                }
                Button("SAVE") { levels.saveLevel(levelName: levelName, updatedBoard: designBoardVM.designedBoard) }
                Button("RESET") { designBoardVM.removeAllPegs() }
                TextField("Level Name", text: $levelName)
                    .textFieldStyle(.roundedBorder)
                    .border(.gray)
                NavigationLink { GameView() } label: {
                    Text("START")
                        .foregroundColor(Color.blue)
                }
            }
        }
        .padding(.all, 20)
        .background(.white)
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
