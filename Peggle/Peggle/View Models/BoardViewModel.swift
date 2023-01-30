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

struct BoardViewModel {
    let maxViewDim: CGFloat = 1_800
    let gridDim: Int
    var board: Board
    var allPegVMs: [PegViewModel]
    /// assume all pegs have the same radius, thus each cell in grid can hold at most one peg reference
    var maxPegRadius: CGFloat
    var grid: [[PegViewModel?]]
    var selectedPegVariant: (String, CGFloat)?
    var selectedAction: Action?

    init(board: Board, maxPegRadius: CGFloat) {
        self.board = board
        self.maxPegRadius = maxPegRadius
        self.gridDim = Int(maxViewDim / maxPegRadius)
        self.grid = Array(repeating: Array(repeating: nil, count: gridDim), count: gridDim)
        self.allPegVMs = []

        for peg in board.allPegs {
            addPeg(peg)
        }
    }

//    mutating func respondToTap(x: CGFloat, y: CGFloat) {
//        if selectedAction == Action.add {
//            tryAddPegAt(x: x, y: y)
//        } else if selectedAction == Action.delete {
//            tryDeletePegAt(x: x, y: y)
//        }
//    }

//    mutating func respondToLongPress(x: CGFloat, y: CGFloat) {
//        tryDeletePegAt(x: x, y: y)
//    }

    mutating func switchToAddPeg(pegVariant: (String, CGFloat)) {
        self.selectedPegVariant = pegVariant
        self.selectedAction = Action.add
    }

    mutating func switchToDeletePeg() {
        self.selectedPegVariant = nil
        self.selectedAction = Action.delete
        print("Action changed to \(self.selectedAction.debugDescription)")
    }

    mutating func tryAddPegAt(x: CGFloat, y: CGFloat) {
        if selectedAction != Action.add {
            return
        }

        let addedPeg = Peg(pegColor: selectedPegVariant!.0, radius: selectedPegVariant!.1, x: x, y: y)
        if isCollidingByGrid(PegViewModel(
            peg: addedPeg,
            row: Int(addedPeg.y / maxPegRadius),
            col: Int(addedPeg.x / maxPegRadius)
        )) {
            return
        }

        addPeg(addedPeg)
    }

    mutating func tryRemovePeg(isLongPress: Bool, targetPegVM: PegViewModel) {
        if isLongPress || selectedAction == Action.delete {
            removePeg(targetPegVM)
        }
    }

//    private mutating func tryDeletePegAt(x: CGFloat, y: CGFloat, isLongPress: Bool) {
//        guard let touchingPeg = getTouchingPeg(x: x, y: y) else {
//            return
//        }
//        print("Might remove peg at " + touchingPeg.peg.x.description + " " + touchingPeg.peg.y.description)
//        if pow(x - touchingPeg.peg.x, 2) + pow(y - touchingPeg.peg.y, 2) > pow(touchingPeg.peg.radius, 2) {
//            return
//        }
//        print("Removing peg at " + touchingPeg.peg.x.description + " " + touchingPeg.peg.y.description)
//        removePeg(touchingPeg)
//    }

    private mutating func addPeg(_ addedPeg: Peg) {
        let pegRow = Int(addedPeg.y / maxPegRadius)
        let pegCol = Int(addedPeg.x / maxPegRadius)
        let pegVM = PegViewModel(peg: addedPeg, row: pegRow, col: pegCol)
        board.addPeg(addedPeg)
        allPegVMs.append(pegVM)
        print("PegVM added to " + pegRow.description + " " + pegCol.description + "\n")
        grid[pegRow][pegCol] = pegVM
    }

    private mutating func removePeg(_ removedPegVM: PegViewModel) {
        allPegVMs.remove(at: allPegVMs.firstIndex(where: { $0.peg.id == removedPegVM.peg.id })!)
        board.removePeg(removedPegVM.peg)
        grid[removedPegVM.row][removedPegVM.col] = nil
    }

    private func isCollidingByGrid(_ thisPegVM: PegViewModel) -> Bool {
        let offsets: [Int] = [-2, -1, 0, 1, 2]
        for offsetX in offsets {
            for offsetY in offsets {
                print("Checking for collision at cell " + (thisPegVM.row + offsetY).description + " " + (thisPegVM.col + offsetX).description)
                guard let pegInCell
                        = grid[max(min(thisPegVM.row + offsetY, gridDim - 1), 0)][max(min(thisPegVM.col + offsetX, gridDim - 1), 0)] else {
                    continue
                }

                if thisPegVM.isCollidingWith(pegInCell) {
                    return true
                }
            }
        }

        return false
    }

    private func getTouchingPeg(x: CGFloat, y: CGFloat) -> PegViewModel? {
        let touchRow = Int(y / maxPegRadius)
        let touchCol = Int(x / maxPegRadius)
        let offsets: [Int] = [-1, 0, 1]
        for offsetX in offsets {
            for offsetY in offsets {
                print("Checking for touch " + (touchRow + offsetY).description + " " + (touchCol + offsetX).description)
                guard let pegInCell
                        = grid[max(min(touchRow + offsetY, gridDim - 1), 0)][max(min(touchCol + offsetX, gridDim - 1), 0)] else {
                    continue
                }

                if pow(x - pegInCell.peg.x, 2) + pow(y - pegInCell.peg.y, 2) <= pow(pegInCell.peg.radius, 2) {
                    return pegInCell
                }
            }
        }
        return nil
    }

    private func isCellOccupied(x: CGFloat, y: CGFloat) -> Bool {
        let row = Int(y / maxPegRadius)
        let col = Int(x / maxPegRadius)
        return grid[row][col] != nil
    }
}
