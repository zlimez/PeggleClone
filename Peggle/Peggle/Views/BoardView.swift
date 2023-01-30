//
//  BoardView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI
import Foundation

struct BoardView: View {
    @State private var boardViewModel = BoardViewModel(board: Board(allPegs: [
        Peg(pegColor: "peg-orange", radius: 30, x: 60, y: 60),
        Peg(pegColor: "peg-blue", radius: 30, x: 150, y: 150)
    ]), maxPegRadius: 30)
    /// Board view should have a @State variable reference to the underlying
    /// board. When it is being tap
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                GeometryReader { geo in
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width)
                }
                ForEach($boardViewModel.allPegVMs) { pegVM in
                    PegView(pegVM: pegVM, parentBoardVM: $boardViewModel)
                }
            }
            .onTapGesture { location in
                boardViewModel.tryAddPegAt(x: location.x, y: location.y)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ControlPanelView(boardViewModel: $boardViewModel)
        }
            .ignoresSafeArea()
    }
}

/// Each peg should detect a drag to move the peg around or a long tap to signal its deletion
struct PegView: View {
    @Binding var pegVM: PegViewModel
    @Binding var parentBoardVM: BoardViewModel

    var body: some View {
        Image(pegVM.color)
            .resizable()
            .frame(width: pegVM.diameter, height: pegVM.diameter)
            .position(x: pegVM.x, y: pegVM.y)
            .onTapGesture(
                perform: { parentBoardVM.tryRemovePeg(isLongPress: false, targetPegVM: pegVM) }
            )
            .onLongPressGesture(
                minimumDuration: 0.5,
                maximumDistance: 10,
                perform: { parentBoardVM.tryRemovePeg(isLongPress: true, targetPegVM: pegVM) }
            )
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BoardView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
        }
    }
}
