//
//  DesignBoard.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

struct DesignBoard {
    static let dummyBoard = DesignBoard(board: Board(allPegs: []))
    static var viewDim: CGSize?
    static var maxDim: Int = 0
    static var blockPalette: [PegVariant] = {
        let brickBlock = PegVariant(
            pegSprite: "brick-block",
            pegLitSprite: "brick-block",
            size: Vector2(x: 96.5, y: 56)
        )
        PegMapper.pegVariantToPegRbTable[brickBlock] = { block in
            Block(block)
        }
        PegMapper.pegVariantToPegTable[brickBlock] = { block in
            BoxPeg(block)
        }
        return [brickBlock]
    }()
    static var palette: [PegVariant] = {
        let orangePeg = PegVariant(
            pegSprite: "peg-orange",
            pegLitSprite: "peg-orange-glow",
            size: Vector2.one * 50
        )
        let bluePeg = PegVariant(
            pegSprite: "peg-blue",
            pegLitSprite: "peg-blue-glow",
            size: Vector2.one * 50
        )
        let purplePeg = PegVariant(
            pegSprite: "peg-purple",
            pegLitSprite: "peg-purple-glow",
            size: Vector2.one * 50
        )
        let greenPeg = PegVariant(
            pegSprite: "peg-green",
            pegLitSprite: "peg-green-glow",
            size: Vector2.one * 50
        )
        let yellowPeg = PegVariant(
            pegSprite: "peg-yellow",
            pegLitSprite: "peg-yellow-glow",
            size: Vector2.one * 50
        )
        PegMapper.pegVariantToPegRbTable[orangePeg] = { peg in
            HostilePeg(peg: peg, captureReward: 150)
        }
        PegMapper.pegVariantToPegTable[orangePeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[bluePeg] = { peg in
            CivilianPeg(peg: peg)
        }
        PegMapper.pegVariantToPegTable[bluePeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[purplePeg] = { peg in
            BoomPeg(peg: peg)
        }
        PegMapper.pegVariantToPegTable[purplePeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[greenPeg] = { peg in
            BondPeg(peg)
        }
        PegMapper.pegVariantToPegTable[greenPeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[yellowPeg] = { peg in
            LoidPeg(peg: peg)
        }
        PegMapper.pegVariantToPegTable[yellowPeg] = { peg in
            CirclePeg(peg)
        }
        return [orangePeg, bluePeg, purplePeg, greenPeg, yellowPeg]
    }()
    static var dimInitialized = false

    var board: Board
    var designPegs: Set<DesignPeg>
    var boundaries: [Boundary]

    static func getEmptyBoard() -> DesignBoard {
        DesignBoard(board: Board(allPegs: []))
    }

    init(board: Board) {
        self.board = board
        designPegs = []
        for peg in board.allPegs {
            guard let pegMaker = PegMapper.pegVariantToPegTable[peg.pegVariant] else {
                fatalError("Peg variant does not exist in mapper")
            }
            designPegs.insert(pegMaker(peg))
        }
        boundaries = []
    }

    mutating func tryAddPegAt(pegVariant: PegVariant, x: CGFloat, y: CGFloat) -> DesignPeg? {
        guard let pegMaker = PegMapper.pegVariantToPegTable[pegVariant] else {
            fatalError("No peg maker matches the peg variant")
        }
        let candidatePeg = pegMaker(Peg(pegVariant: pegVariant, transform: Transform(Vector2(x: x, y: y))))
        if willCollide(candidatePeg) {
            return nil
        }

        addPeg(candidatePeg)
        return candidatePeg
    }
    
    mutating func tryRotatePeg(targetPeg: DesignPeg, newRotation: CGFloat) {
        let originalRotation = targetPeg.peg.transform.rotation
        targetPeg.rotateTo(newRotation)
        if willCollide(targetPeg) {
            targetPeg.rotateTo(originalRotation)
        }
    }
    
    mutating func tryScalePeg(targetPeg: DesignPeg, newScale: Vector2) {
        var calibratedScale = newScale
        if targetPeg.isCircle() {
            calibratedScale = Vector2.one * newScale.x
        }
        let originalScale = targetPeg.peg.transform.scale
        targetPeg.scaleTo(calibratedScale)
        if willCollide(targetPeg) {
            targetPeg.scaleTo(originalScale)
        }
    }

    mutating func tryMovePeg(targetPeg: DesignPeg, destination: Vector2) {
        let originalPosition = targetPeg.peg.transform.position
        targetPeg.updatePositionTo(destination)
        if willCollide(targetPeg) {
            targetPeg.updatePositionTo(originalPosition)
        }
    }

    mutating func removeAllPegs() {
        designPegs.removeAll()
        board.removeAllPegs()
    }

    mutating func initDim(_ viewDim: CGSize) {
        DesignBoard.viewDim = viewDim
        DesignBoard.dimInitialized = true
        
        let topBound = Boundary(
            boxCollider: BoxCollider(halfWidth: viewDim.width / 2, halfHeight: Boundary.boundHalfThickness),
            transform: Transform(Vector2(x: viewDim.width / 2, y: -Boundary.boundHalfThickness))
        )
        let downBound = Boundary(
            boxCollider: BoxCollider(halfWidth: viewDim.width / 2, halfHeight: Boundary.boundHalfThickness),
            transform: Transform(Vector2(x: viewDim.width / 2, y: viewDim.height + Boundary.boundHalfThickness))
        )
        let leftBound = Boundary(
            boxCollider: BoxCollider(halfWidth: Boundary.boundHalfThickness, halfHeight: viewDim.height / 2),
            transform: Transform(Vector2(x: -Boundary.boundHalfThickness, y: viewDim.height / 2))
        )
        let rightBound = Boundary(
            boxCollider: BoxCollider(halfWidth: Boundary.boundHalfThickness, halfHeight: viewDim.height / 2),
            transform: Transform(Vector2(x: viewDim.width + Boundary.boundHalfThickness, y: viewDim.height / 2))
        )
        boundaries.append(topBound)
        boundaries.append(downBound)
        boundaries.append(leftBound)
        boundaries.append(rightBound)
    }

    private mutating func addPeg(_ addedPeg: DesignPeg) {
        designPegs.insert(addedPeg)
        board.addPeg(addedPeg.peg)
    }

    mutating func removePeg(_ removedPeg: DesignPeg) {
        designPegs.remove(removedPeg)
        board.removePeg(removedPeg.peg)
    }

    // Pegs yet to be created will have the special id -1
    private func willCollide(_ targetPeg: DesignPeg) -> Bool {
        // Collides with play area border
        if boundaries.contains(where: { boundary in boundary.isCollidingWith(targetPeg)} ) {
            return true
        }

        for designPeg in designPegs {
            if designPeg != targetPeg && designPeg.isCollidingWith(targetPeg) {
                return true
            }
        }

        return false
    }
}

struct Boundary {
    static let boundHalfThickness: CGFloat = 10
    var boxCollider: BoxCollider
    var transform: Transform

    func isCollidingWith(_ designPeg: DesignPeg) -> Bool {
        guard let pegCollider = designPeg.collider else {
            fatalError("Peg on design board does not have a collider attached")
        }
        return boxCollider.testCollision(
            transform: transform,
            otherCollider: pegCollider,
            otherTransform: designPeg.peg.transform
        ).hasCollision
    }
}

struct PegVariant: Hashable {
    let pegSprite: String
    let pegLitSprite: String
    let size: Vector2

    static func == (lhs: PegVariant, rhs: PegVariant) -> Bool {
        lhs.pegSprite == rhs.pegSprite && lhs.pegLitSprite == rhs.pegLitSprite && lhs.size == rhs.size
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pegSprite)
        hasher.combine(pegLitSprite)
        hasher.combine(size)
    }
}

extension PegVariant: Codable {}
