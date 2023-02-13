//
//  Board.swift
//  Peggle
//
//  Created by James Chiu on 29/1/23.
//

import Foundation

struct DesignBoard: Codable {
    static var palette = [
        PegVariant(pegColor: "peg-orange", pegRadius: 30),
        PegVariant(pegColor: "peg-blue", pegRadius: 30)
    ]
    static var dimInitialized = false
    
    var board: Board
    let unitPegRadius: CGFloat = 30
    var grid: [[Peg?]]
    
    static func getEmptyBoard() -> DesignBoard {
        DesignBoard(board: Board(allPegs: Set()))
    }
    
    init(board: Board) {
        self.board = board

        if BoardViewModel.dimInitialized {
            self.grid = Array(
                repeating: Array(repeating: nil, count: BoardViewModel.maxDim),
                count: BoardViewModel.maxDim
            )
            board.allPegs.forEach { peg in addPeg(peg) }
        } else {
            self.grid = [[]]
            board.allPegs.forEach { peg in initPeg(peg) }
        }
    }

    mutating func tryAddPegAt(x: CGFloat, y: CGFloat, pegColor: String) {
        if willCollide(pegRadius: unitPegRadius, pegX: x, pegY: y) {
            return
        }
        
        let pegRow = pointToGrid(x)
        let pegCol = pointToGrid(y)

        let addedPeg = Peg(pegColor: pegColor, unitRadius: unitPegRadius, x: x, y: y, row: pegRow, col: pegCol)
        addPeg(addedPeg)
    }

    mutating func tryRemovePeg(isLongPress: Bool, targetPeg: Peg) {
        removePeg(targetPeg)
    }

    mutating func tryMovePeg(targetPeg: Peg, destination: Vector2) {
        if willCollide(pegRadius: targetPeg.unitRadius, pegX: destination.x, pegY: destination.y, pegId: targetPeg.id) {
            return
        }

        let newRow = pointToGrid(destination.y)
        let newCol = pointToGrid(destination.x)

        grid[targetPeg.row][targetPeg.col] = nil
        grid[newRow][newCol] = targetPeg
        targetPeg.updatePositionTo(newPosition: destination, newRow: newRow, newCol: newCol)
    }

    mutating func removeAllPegs() {
        board.removeAllPegs()
        self.grid = Array(repeating: Array(repeating: nil, count: grid.count), count: grid.count)
    }

    mutating func initGrid(_ viewDim: CGSize) {
        BoardViewModel.viewDim = viewDim
        BoardViewModel.maxDim = Int(round(max(viewDim.width / self.maxPegRadius, viewDim.height / self.maxPegRadius)))
        print("Max dim \(BoardViewModel.maxDim)")
        self.grid = Array(repeating: Array(repeating: nil, count: BoardViewModel.maxDim), count: BoardViewModel.maxDim)
        for initPegVM in allPegVMs {
            self.grid[initPegVM.row][initPegVM.col] = initPegVM
        }
        BoardViewModel.dimInitialized = true
    }

    private mutating func initPeg(_ savedPeg: Peg) {
        let pegRow = pointToGrid(savedPeg.transform.position.y)
        let pegCol = pointToGrid(savedPeg.transform.position.x)
        let pegVM = PegViewModel(peg: savedPeg, row: pegRow, col: pegCol)
        board.addPeg(savedPeg)
        allPegVMs.append(pegVM)
    }

    private mutating func addPeg(_ addedPeg: Peg) {
        board.addPeg(addedPeg)
        allPegVMs.append(pegVM)
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
        if pegX < pegRadius || pegX > BoardViewModel.viewDim!.width - pegRadius
            || pegY < pegRadius || pegY > BoardViewModel.viewDim!.height - pegRadius {
            return true
        }

        let thisPegRow = pointToGrid(pegY)
        let thisPegCol = pointToGrid(pegX)
        let offsets: [Int] = [-2, -1, 0, 1, 2]
        for offsetX in offsets {
            for offsetY in offsets {
                let adjacentRow = max(min(thisPegRow + offsetY, grid.count - 1), 0)
                let adjacentCol = max(min(thisPegCol + offsetX, grid.count - 1), 0)
                guard let pegInCell = grid[adjacentRow][adjacentCol] else {
                    continue
                }

                if pegInCell.isCollidingWith(
                    otherPegRadius: pegRadius,
                    otherPegX: pegX,
                    otherPegY: pegY,
                    otherPegId: pegId
                ) {
                    return true
                }
            }
        }

        return false
    }

    private func pointToGrid(_ point: CGFloat) -> Int {
        Int(point / unitPegRadius)
    }

    /// Required to provide copy of pegs and not peg references
    func getCopy() -> DesignBoard {
        var allPegsCopy = Set<Peg>()
        for peg in allPegs {
            allPegsCopy.insert(peg.getCopy())
        }
        return DesignBoard(allPegs: allPegsCopy)
    }
}

struct PegVariant: Equatable {
    let pegColor: String
    let pegRadius: CGFloat

    static func == (lhs: PegVariant, rhs: PegVariant) -> Bool {
        lhs.pegColor == rhs.pegColor && lhs.pegRadius == rhs.pegRadius
    }
}
