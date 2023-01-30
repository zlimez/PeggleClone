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
    /// tryMovePeg() doesn't trigger UI rerender, seems to shallow compare grid state to determine if a rerender is necessary
    var forceUpdate = 1
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

        if willCollide(pegRadius: selectedPegRadius, pegX: x, pegY: y) {
            return
        }

        let addedPeg = Peg(pegColor: selectedPegColor, radius: selectedPegRadius, x: x, y: y)
        addPeg(addedPeg)
    }

    mutating func tryRemovePeg(isLongPress: Bool, targetPegVM: PegViewModel) {
        if isLongPress || selectedAction == Action.delete {
            removePeg(targetPegVM)
        }
    }

    mutating func tryMovePeg(targetPegVM: PegViewModel, destination: CGPoint) {
        if targetPegVM.isBlocked {
            return
        }

        if willCollide(pegRadius: targetPegVM.radius, pegX: destination.x, pegY: destination.y, pegId: targetPegVM.id) {
            targetPegVM.isBlocked = true
            return
        }

        forceUpdate *= -1
        let newRow = pointToGrid(destination.y)
        let newCol = pointToGrid(destination.x)
        // The conditional clause is not required when the assumption that all pegs are of same size holds
        grid[targetPegVM.row][targetPegVM.col] = nil
        grid[newRow][newCol] = targetPegVM
        targetPegVM.updatePosition(newPosition: destination, newRow: newRow, newCol: newCol)
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
        let pegRow = pointToGrid(savedPeg.y)
        let pegCol = pointToGrid(savedPeg.x)
        let pegVM = PegViewModel(peg: savedPeg, row: pegRow, col: pegCol)
        board.addPeg(savedPeg)
        allPegVMs.append(pegVM)
    }

    private mutating func addPeg(_ addedPeg: Peg) {
        let pegRow = pointToGrid(addedPeg.y)
        let pegCol = pointToGrid(addedPeg.x)
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

    // Pegs yet to be created will have the special id -1
    private func willCollide(pegRadius: CGFloat, pegX: CGFloat, pegY: CGFloat, pegId: Int = -1) -> Bool {
        // Collides with play area border
        if pegX < pegRadius || pegX > viewDim!.width - pegRadius
            || pegY < pegRadius || pegY > viewDim!.height - pegRadius {
            return true
        }
        
        let thisPegRow = pointToGrid(pegY)
        let thisPegCol = pointToGrid(pegX)
        let offsets: [Int] = [-2, -1, 0, 1, 2]
        for offsetX in offsets {
            for offsetY in offsets {
//                print("Checking for collision at cell " + (thisPegRow + offsetY).description + " " + (thisPegCol + offsetX).description)
                guard let pegInCell
                        = grid[max(min(thisPegRow + offsetY, grid.count - 1), 0)][max(min(thisPegCol + offsetX, grid.count - 1), 0)] else {
                    continue
                }

                if pegInCell.isCollidingWith(otherPegRadius: pegRadius, otherPegX: pegX, otherPegY: pegY, otherPegId: pegId) {
                    print("Colliding with \(pegInCell.id.description) \(pegInCell.color)")
                    return true
                }
            }
        }

        return false
    }
        
    private func pointToGrid(_ point: CGFloat) -> Int {
        return Int(point / maxPegRadius)
    }
}
