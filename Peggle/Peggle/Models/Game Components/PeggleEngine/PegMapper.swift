//
//  PegMapper.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

final class PegMapper {
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
        let redPeg = PegVariant(
            pegSprite: "peg-green",
            pegLitSprite: "peg-green-glow",
            size: Vector2.one * 50
        )
        let bluePeg = PegVariant(
            pegSprite: "peg-blue",
            pegLitSprite: "peg-blue-glow",
            size: Vector2.one * 50
        )
        let yorPeg = PegVariant(
            pegSprite: "yor-flustered",
            pegLitSprite: "explode",
            size: Vector2.one * 60
        )
        let bondPeg = PegVariant(
            pegSprite: "bond-stone",
            pegLitSprite: "bond-swag",
            size: Vector2.one * 60
        )
        let loidPeg = PegVariant(
            pegSprite: "loid-happy",
            pegLitSprite: "loid-serious",
            size: Vector2.one * 60
        )
        let frankPeg = PegVariant(
            pegSprite: "franky-annoyed",
            pegLitSprite: "franky-happy",
            size: Vector2.one * 60
        )
        let trianglePurplePeg = PegVariant(
            pegSprite: "peg-purple-triangle",
            pegLitSprite: "peg-purple-glow-triangle",
            size: Vector2(x: 50, y: 25 * sqrt(3))
        )
        PegMapper.pegVariantToPegRbTable[orangePeg] = { peg in
            HostilePeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2), captureReward: 150)
        }
        PegMapper.pegVariantToPegTable[orangePeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToPegRbTable[redPeg] = { peg in
            HostilePeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2), captureReward: 500)
        }
        PegMapper.pegVariantToPegTable[redPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToPegRbTable[bluePeg] = { peg in
            CivilianPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[bluePeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToPegRbTable[yorPeg] = { peg in
            BoomPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[yorPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToPegRbTable[bondPeg] = { peg in
            BondPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[bondPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToPegRbTable[loidPeg] = { peg in
            LoidPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[loidPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToPegRbTable[frankPeg] = { peg in
            ChancePeg(
                peg: peg,
                collider: BoxCollider(halfWidth: peg.unitWidth / 2, halfHeight: peg.unitHeight / 2)
            )
        }
        PegMapper.pegVariantToPegTable[frankPeg] = { peg in BoxPeg(peg) }
        PegMapper.pegVariantToPegRbTable[trianglePurplePeg] = { peg in
            ConfusePeg(
                peg: peg,
                collider: PolygonCollider(
                    stdVertices: [
                        Vector2(x: -peg.unitWidth / 2, y: -peg.unitHeight / 3),
                        Vector2(x: 0, y: peg.unitHeight / 3 * 2),
                        Vector2(x: peg.unitWidth / 2, y: -peg.unitHeight / 3)
                    ],
                    isBox: false
                )
            )
        }
        PegMapper.pegVariantToPegTable[trianglePurplePeg] = { peg in TrianglePeg(peg) }
        return [orangePeg, redPeg, bluePeg, yorPeg, bondPeg, loidPeg, frankPeg, trianglePurplePeg]
    }()
    private static var pegVariantToPegTable: [PegVariant: (Peg) -> DesignPeg] = [:]
    private static var pegVariantToPegRbTable: [PegVariant: (Peg) -> PegRB] = [:]

    static func getPegMaker(_ pegVariant: PegVariant) -> (Peg) -> DesignPeg {
        if pegVariantToPegTable.isEmpty || pegVariantToPegRbTable.isEmpty {
            _ = PegMapper.palette
            _ = PegMapper.blockPalette
        }

        guard let pegMaker = pegVariantToPegTable[pegVariant] else {
            fatalError("Palette does not contain this saved peg")
        }
        return pegMaker
    }

    static func getPegRbMaker(_ pegVariant: PegVariant) -> (Peg) -> PegRB {
        if pegVariantToPegTable.isEmpty || pegVariantToPegRbTable.isEmpty {
            _ = PegMapper.palette
            _ = PegMapper.blockPalette
        }

        guard let pegRbMaker = pegVariantToPegRbTable[pegVariant] else {
            fatalError("Palette does not contain this saved peg")
        }
        return pegRbMaker
    }
}
