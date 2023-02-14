//
//  BoardViewModel.swift
//  Peggle
//
//  Created by James Chiu on 29/1/23.
//

import Foundation

enum Action {
    case add, delete
}

struct DesignBoardVM {
    var selectedPegVariant: PegVariant?
    var selectedAction: Action?
    var dragUpdate = 1
    var designBoard: DesignBoard
    var pegVMs: [PegVM] = []
    var designedBoard: Board {
        designBoard.board
    }
    
    init(_ designBoard: DesignBoard) {
        self.designBoard = designBoard
        pegVMs = designBoard.allPegs.map { peg in PegVM(peg) }
    }

    static func getEmptyBoard() -> DesignBoardVM {
        DesignBoardVM(DesignBoard.getEmptyBoard())
    }

    func isVariantActive(_ pegVariant: PegVariant) -> Bool {
        selectedAction == Action.add && selectedPegVariant == pegVariant
    }

    mutating func switchToAddPeg(_ pegVariant: PegVariant) {
        self.selectedPegVariant = pegVariant
        self.selectedAction = Action.add
    }

    mutating func switchToDeletePeg() {
        self.selectedPegVariant = nil
        self.selectedAction = Action.delete
    }

    mutating func tryAddPegAt(x: CGFloat, y: CGFloat) {
        if selectedAction != Action.add {
            return
        }

        guard let selectedPegColor = selectedPegVariant?.pegColor,
                let selectedPegRadius = selectedPegVariant?.pegRadius else {
            print("No peg variant from palette selected when trying to add a peg")
            return
        }

        guard let addedPeg = designBoard.tryAddPegAt(
            pegColor: selectedPegColor,
            radius: selectedPegRadius,
            x: x,
            y: y
        ) else {
            return
        }

        pegVMs.append(PegVM(addedPeg))
    }

    mutating func tryRemovePeg(isLongPress: Bool, targetPeg: Peg) {
        if isLongPress || selectedAction == Action.delete {
            designBoard.removePeg(targetPeg)
            pegVMs = pegVMs.filter { $0.id != targetPeg.id }
        }
    }

    mutating func tryMovePeg(targetPeg: Peg, destination: CGPoint) {
        dragUpdate *= -1
        designBoard.tryMovePeg(targetPeg: targetPeg, destination: Vector2(x: destination.x, y: destination.y))
    }

    mutating func removeAllPegs() {
        pegVMs.removeAll()
        designBoard.removeAllPegs()
    }

    mutating func initGrid(_ viewDim: CGSize) {
        designBoard.initGrid(viewDim)
    }
}
