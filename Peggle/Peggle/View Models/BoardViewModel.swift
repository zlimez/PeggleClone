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
    var viewDim: CGSize?
    var board: Board
    var allPegVMs: [PegViewModel]
    /// assume all pegs have the same radius, thus each cell in grid can hold at most one peg reference
    var maxPegRadius: CGFloat
    var grid: [[PegViewModel?]]
    var gridInitialized = false
    var selectedPegVariant: (String, CGFloat)?
    var selectedAction: Action?

    init(board: Board, maxPegRadius: CGFloat) {
        self.board = board
        self.maxPegRadius = maxPegRadius
        self.allPegVMs = []
        self.grid = [[]]

        for peg in board.allPegs {
            initPeg(peg)
        }
    }

    mutating func switchToAddPeg(pegVariant: (String, CGFloat)) {
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

        let selectedPegColor = selectedPegVariant!.0
        let selectedPegRadius = selectedPegVariant!.1
        if x < selectedPegRadius || x > viewDim!.width - selectedPegRadius
            || y < selectedPegRadius || y > viewDim!.height - selectedPegRadius {
            return
        }

        let addedPeg = Peg(pegColor: selectedPegColor, radius: selectedPegRadius, x: x, y: y)
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

    mutating func removeAllPegs() {
        allPegVMs.removeAll()
        board.removeAllPegs()
        self.grid = Array(repeating: Array(repeating: nil, count: grid.count), count: grid.count)
    }

    mutating func initEmptyGrid(_ viewDim: CGSize) {
        self.viewDim = viewDim
        let maxDim = Int(round(max(viewDim.width / self.maxPegRadius, viewDim.height / self.maxPegRadius)))
        print("Max dim \(maxDim)")
        self.grid = Array(repeating: Array(repeating: nil, count: maxDim), count: maxDim)
        for initPegVM in allPegVMs {
            self.grid[initPegVM.row][initPegVM.col] = initPegVM
        }
        self.gridInitialized = true
    }

    /// Used only for pegs saved from last session. Grid dimension not determined yet hence pegVM cannot be added to grid.
    private mutating func initPeg(_ savedPeg: Peg) {
        let pegRow = Int(savedPeg.y / maxPegRadius)
        let pegCol = Int(savedPeg.x / maxPegRadius)
        let pegVM = PegViewModel(peg: savedPeg, row: pegRow, col: pegCol)
        board.addPeg(savedPeg)
        allPegVMs.append(pegVM)
    }

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
                        = grid[max(min(thisPegVM.row + offsetY, grid.count - 1), 0)][max(min(thisPegVM.col + offsetX, grid.count - 1), 0)] else {
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
                        = grid[max(min(touchRow + offsetY, grid.count - 1), 0)][max(min(touchCol + offsetX, grid.count - 1), 0)] else {
                    continue
                }

                if pow(x - pegInCell.peg.x, 2) + pow(y - pegInCell.peg.y, 2) <= pow(pegInCell.peg.radius, 2) {
                    return pegInCell
                }
            }
        }
        return nil
    }
}
