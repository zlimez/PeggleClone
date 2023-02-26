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

class DesignBoardVM: ObservableObject {
    @Published var selectedPegVariant: PegVariant?
    @Published var selectedAction: Action?
    @Published var pegVMs: [PegVM] = []
    @Published var selectedPeg: PegVM
    // Used to forced swiftUI to rerender when peg is moved
    @Published var pegPositionUpdate = 1
    private var dummyPegVM = PegVM(peg: Peg.dummyPeg)
    var designBoard: DesignBoard

    var hasSelectedPeg: Bool {
        selectedPeg.id != Peg.dummyPeg.id
    }

    var designedBoard: Board {
        designBoard.board
    }

    init() {
        self.designBoard = DesignBoard.getEmptyBoard()
        self.selectedPeg = dummyPegVM
    }

    func setNewBoard(_ designBoard: DesignBoard) {
        pegVMs.removeAll()

        self.designBoard = designBoard
        self.selectedPeg = dummyPegVM
        pegVMs = designBoard.allPegs.map { peg in PegVM(peg: peg) }
    }

    func isVariantActive(_ pegVariant: PegVariant) -> Bool {
        selectedAction == Action.add && selectedPegVariant == pegVariant
    }

    func deselectPeg() {
        if hasSelectedPeg {
            selectedPeg = dummyPegVM
        }
    }

    func switchToAddPeg(_ pegVariant: PegVariant) {
        self.selectedPegVariant = pegVariant
        self.selectedAction = Action.add
    }

    func switchToDeletePeg() {
        self.selectedPegVariant = nil
        self.selectedAction = Action.delete
    }

   func tryAddPegAt(x: CGFloat, y: CGFloat) -> Bool {
        if selectedAction != Action.add {
            return false
        }

        guard let selectedPegVariant = selectedPegVariant else {
            print("No peg variant from palette selected when trying to add a peg")
            return false
        }

        guard let addedPeg = designBoard.tryAddPegAt(
            pegVariant: selectedPegVariant, x: x, y: y
        ) else {
            return false
        }

        pegVMs.append(PegVM(peg: addedPeg))
        return true
    }

    func selectOrRemovePeg(isLongPress: Bool, targetPegVM: PegVM) {
        if isLongPress || selectedAction == Action.delete {
            designBoard.removePeg(targetPegVM.peg)
            pegVMs = pegVMs.filter { $0.id != targetPegVM.id }
        } else {
            selectedPeg = targetPegVM
        }
    }

    func tryMovePeg(targetPegVM: PegVM, destination: CGPoint) {
        pegPositionUpdate *= -1
        designBoard.tryMovePeg(targetPeg: targetPegVM.peg, destination: Vector2(x: destination.x, y: destination.y))
    }

    func removeAllPegs() {
        pegVMs.removeAll()
        designBoard.removeAllPegs()
    }

    func initGrid(_ viewDim: CGSize) {
        designBoard.initGrid(viewDim)
    }
}
