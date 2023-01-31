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
    static var palette = [
        PegVariant(pegColor: "peg-orange", pegRadius: 30),
        PegVariant(pegColor: "peg-blue", pegRadius: 30)
    ]
    /// Requires a dragUpdate to force rerender since properties are only shallow compared
    private var dragUpdate = 1
    private var viewDim: CGSize?
    var board: Board
    var allPegVMs: [PegViewModel]
    /// assume all pegs have the same radius, thus each cell in grid can hold at most one peg reference
    var maxPegRadius: CGFloat
    var grid: [[PegViewModel?]]
    var gridInitialized = false
    var selectedPegVariant: PegVariant?
    var selectedAction: Action?

    init(board: Board) {
        self.board = board
        self.allPegVMs = []
        self.grid = [[]]
        self.maxPegRadius = BoardViewModel.palette.reduce(-1, { max($0, $1.pegRadius) })

        for peg in board.allPegs {
            initPeg(peg)
        }
    }
    
    static func getEmptyBoard() -> BoardViewModel {
        BoardViewModel(board: Board(allPegs: Set()))
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
        
        guard let selectedPegColor = selectedPegVariant?.pegColor, let selectedPegRadius = selectedPegVariant?.pegRadius else {
            print("No peg variant from palette selected when trying to add a peg")
            return
        }

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

        dragUpdate *= -1
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
                guard let pegInCell
                        = grid[max(min(thisPegRow + offsetY, grid.count - 1), 0)][max(min(thisPegCol + offsetX, grid.count - 1), 0)] else {
                    continue
                }

                if pegInCell.isCollidingWith(
                    otherPegRadius: pegRadius,
                    otherPegX: pegX,
                    otherPegY: pegY,
                    otherPegId: pegId
                ) {
                    print("Colliding with \(pegInCell.id.description) \(pegInCell.color)")
                    return true
                }
            }
        }

        return false
    }

    private func pointToGrid(_ point: CGFloat) -> Int {
        Int(point / maxPegRadius)
    }
}

struct PegVariant: Equatable {
    let pegColor: String
    let pegRadius: CGFloat
    
    static func == (lhs: PegVariant, rhs: PegVariant) -> Bool {
        lhs.pegColor == rhs.pegColor && lhs.pegRadius == rhs.pegRadius
    }
}
