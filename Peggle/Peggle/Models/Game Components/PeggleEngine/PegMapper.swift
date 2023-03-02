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
        let trianglePurplePeg = PegVariant(
            pegSprite: "peg-purple-triangle",
            pegLitSprite: "peg-purple-glow-triangle",
            size: Vector2(x: 50, y: 25 * sqrt(3))
        )
        PegMapper.pegVariantToPegRbTable[orangePeg] = { peg in
            HostilePeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2), captureReward: 150)
        }
        PegMapper.pegVariantToPegTable[orangePeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[bluePeg] = { peg in
            CivilianPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[bluePeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[purplePeg] = { peg in
            BoomPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[purplePeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[greenPeg] = { peg in
            BondPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[greenPeg] = { peg in
            CirclePeg(peg)
        }
        PegMapper.pegVariantToPegRbTable[yellowPeg] = { peg in
            LoidPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[yellowPeg] = { peg in
            CirclePeg(peg)
        }
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
        PegMapper.pegVariantToPegTable[trianglePurplePeg] = { peg in
            TrianglePeg(peg)
        }
        return [orangePeg, bluePeg, purplePeg, greenPeg, yellowPeg, trianglePurplePeg]
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
