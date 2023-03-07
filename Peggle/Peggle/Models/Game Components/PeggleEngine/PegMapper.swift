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

    private static var palette: [PegVariant] = []
    private static var pegVariantToPegTable: [PegVariant: (Peg) -> DesignPeg] = [:]
    private static var pegVariantToPegRbTable: [PegVariant: (Peg) -> PegRB] = [:]
    private static var pegVariantToDetailsTable: [PegVariant: String] = [:]

    static func initAllPegs() -> [PegVariant] {
        let orangePeg = PegVariant(
            pegSprite: "peg-orange",
            pegLitSprite: "peg-orange-glow",
            size: Vector2.one * 50
        )
        let greenPeg = PegVariant(
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
        PegMapper.pegVariantToPegRbTable[orangePeg] = { peg in
            HostilePeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2), captureReward: 150)
        }
        PegMapper.pegVariantToPegTable[orangePeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToDetailsTable[orangePeg] = "Small time mobsters"
                + " stirring up trouble between Westalis and Ostania."
        PegMapper.pegVariantToPegRbTable[greenPeg] = { peg in
            HostilePeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2), captureReward: 500)
        }
        PegMapper.pegVariantToPegTable[greenPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToDetailsTable[greenPeg] = "Pro war political elites that controls"
                + " the economy of Ostania."
        PegMapper.pegVariantToPegRbTable[bluePeg] = { peg in
            CivilianPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[bluePeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToDetailsTable[bluePeg] = "Innocent civilians blessed with dangerous bliss."
        PegMapper.pegVariantToPegRbTable[yorPeg] = { peg in
            BoomPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[yorPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToDetailsTable[yorPeg] = "Yor Briar. An assassin with explosive"
                + " strength that obliterates people around her, friends and foes alike."

        var pegSet = [orangePeg, greenPeg, bluePeg, yorPeg]
        pegSet.append(contentsOf: initSecondPegSet())
        return pegSet
    }

    private static func initSecondPegSet() -> [PegVariant] {
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
        PegMapper.pegVariantToPegRbTable[bondPeg] = { peg in
            BondPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[bondPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToDetailsTable[bondPeg] = "Bond. A relic of unspeakable experiments"
                + " conducted in Ostania. With him by your side, you get a second shot."
        PegMapper.pegVariantToPegRbTable[loidPeg] = { peg in
            LoidPeg(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
        }
        PegMapper.pegVariantToPegTable[loidPeg] = { peg in CirclePeg(peg) }
        PegMapper.pegVariantToDetailsTable[loidPeg] = "Loid Forger, code name Twilight. A superb"
                + " agent that might help you reverse the tides of the mission."
        PegMapper.pegVariantToPegRbTable[frankPeg] = { peg in
            ChancePeg(
                peg: peg,
                collider: BoxCollider(halfWidth: peg.unitWidth / 2, halfHeight: peg.unitHeight / 2)
            )
        }
        PegMapper.pegVariantToPegTable[frankPeg] = { peg in BoxPeg(peg) }
        PegMapper.pegVariantToDetailsTable[frankPeg] = "Franky. A pesky informant, that will"
                + " grant you favors, well occasionally"
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
        PegMapper.pegVariantToDetailsTable[trianglePurplePeg] = "A mysterious item."
                + " As above so below."
        return [bondPeg, loidPeg, frankPeg, trianglePurplePeg]
    }

    static func getPalette() -> [PegVariant] {
        if palette.isEmpty {
            palette = initAllPegs()
        }
        return palette
    }

    static func getPegMaker(_ pegVariant: PegVariant) -> (Peg) -> DesignPeg {
        if palette.isEmpty {
            palette = initAllPegs()
            _ = blockPalette
        }

        guard let pegMaker = pegVariantToPegTable[pegVariant] else {
            fatalError("Palette does not contain this saved peg")
        }
        return pegMaker
    }

    static func getPegRbMaker(_ pegVariant: PegVariant) -> (Peg) -> PegRB {
        if palette.isEmpty {
            palette = initAllPegs()
            _ = blockPalette
        }

        guard let pegRbMaker = pegVariantToPegRbTable[pegVariant] else {
            fatalError("Palette does not contain this saved peg")
        }
        return pegRbMaker
    }

    static func getPegDetails(_ pegVariant: PegVariant) -> String {
        if palette.isEmpty {
            palette = initAllPegs()
            _ = blockPalette
        }

        guard let pegDetails = pegVariantToDetailsTable[pegVariant] else {
            fatalError("Palette does not contain this saved peg")
        }
        return pegDetails
    }
}
