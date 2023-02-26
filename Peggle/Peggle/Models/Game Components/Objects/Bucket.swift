//
//  Bucket.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class Bucket: VisibleRigidBody {
    // The bucket oscillates between these two coordinates
    var leftEnd: CGFloat
    var center: CGFloat
    var rightEnd: CGFloat
    var period: CGFloat
    private let initTime: Double

    init(transform: Transform, center: CGFloat, leftEnd: CGFloat, rightEnd: CGFloat, period: CGFloat = 5) {
        self.center = center
        self.leftEnd = leftEnd
        self.rightEnd = rightEnd
        self.period = period
        guard let activeGameBoard = GameWorld.activeGameBoard else {
            fatalError("No active board")
        }
        self.initTime = activeGameBoard.gameTime

        let spriteContainer = SpriteContainer(
            sprite: "bucket",
            unitWidth: 100,
            unitHeight: 114
        )
        super.init(
            bodyType: BodyType.kinematic,
            material: Material.triggerMaterial,
            collider: BoxCollider(halfWidth: 55.5, halfHeight: 57),
            spriteContainer: spriteContainer,
            transform: transform,
            isTrigger: true
        )

        // Removal would not be invoked here
        activeGameBoard.addCoroutine(Coroutine(routine: oscillate, onCompleted: activeGameBoard.removeCoroutine))
    }
    
    func shut() {
        isTrigger = false
    }
    
    func open() {
        isTrigger = true
    }

    func oscillate(deltaTime: Double) -> Bool {
        guard let activeGameBoard = GameWorld.activeGameBoard else {
            return true
        }

        let elapsedTime = activeGameBoard.gameTime - initTime
        let normalizedTime = elapsedTime.truncatingRemainder(dividingBy: period) / period
        transform.position = Vector2(
            x: Lerper.sinLerpFloat(
                center: center,
                maximum: rightEnd,
                minimum: leftEnd,
                t: normalizedTime
            ),
            y: transform.position.y
        )
        return false
    }

    override func onTriggerEnter(_ collision: Collision) {
        super.onTriggerEnter(collision)
        if let cannonBall = collision.rbB as? CannonBall {
            GameWorld.activeGameBoard?.numOfBalls += 1
            GameWorld.activeGameBoard?.removeCannonBall(cannonBall)
            GameWorld.activeGameBoard?.fadeCollidedPegs()

        }
    }
}
