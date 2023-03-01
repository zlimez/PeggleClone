//
//  PegRB.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

// Considers block as a peg, during design there is no behaviour difference
// hence I do not see the need to intentionally consider it separately other
// than having a different set of a behaviour as with peg variants
class PegRB: VisibleRigidBody {
    let peg: Peg
    var unitWidth: CGFloat { peg.unitWidth }
    var unitHeight: CGFloat { peg.unitHeight }

    lazy var makeFlipRotator: (Vector2) -> (Double) -> Bool = { [unowned self] (center: Vector2) in
        guard bodyType == BodyType.stationary else {
            fatalError("Board wise rotation should not be called on non stationary pegs")
        }
        let initRelativePosition = transform.position - center
        let targetRelativePosition = -initRelativePosition
        let initRotation = transform.rotation
        let angleToBeRotated = CGFloat.pi
        var timeElapsed: Double = 0
        func flipUpsideDown(deltaTime: Double) -> Bool {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }
            let ratioTime = timeElapsed / activeGameBoard.flipTimeInterval
            let angleRotated = Lerper.cubicLerpFloat(from: 0, to: angleToBeRotated, t: ratioTime)
            let currRelativePosition = initRelativePosition.rotateBy(angleRotated)
            transform.position = center + currRelativePosition
            transform.rotation = initRotation + angleRotated

            if ratioTime >= 1 {
                return true
            }
            timeElapsed += deltaTime
            return false
        }
        return flipUpsideDown
    }

    init(peg: Peg, collider: Collider) {
        self.peg = peg
        let spriteContainer = SpriteContainer(
            sprite: peg.pegSprite,
            unitWidth: peg.unitWidth,
            unitHeight: peg.unitHeight
        )
        super.init(
            bodyType: BodyType.stationary,
            material: Material.staticMaterial,
            collider: collider,
            spriteContainer: spriteContainer,
            transform: peg.transform
        )
    }
}
