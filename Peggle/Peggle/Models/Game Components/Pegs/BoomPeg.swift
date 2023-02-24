//
//  BoomPeg.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class BoomPeg: PegRB, Animated {
    // TODO: Animate explosion
    var idleSprite: String = ""
    var spriteSheet: [String] = []
    var animateSequences: [String : [Int]] = [:]
    var frameRate: Float = 0

    var explosionScale: CGFloat
    // Increments by scaling the trigger object
    var explosionSpeed: Vector2
    var explosionImpulse: CGFloat
    var exploded = false
    private let initScale: CGFloat

    init(
        peg: Peg,
        explosionRatio: CGFloat = 5,
        explosionSpeed: Vector2 = Vector2.one * 2.5,
        explosionImpulse: CGFloat = 10000
    ) {
        // Bigger the peg, bigger the explosion radius
        self.initScale = peg.transform.scale.x
        self.explosionScale = initScale * explosionRatio
        self.explosionSpeed = explosionSpeed
        self.explosionImpulse = explosionImpulse
        super.init(peg)
    }

    func explode(deltaTime: Double) -> Bool {
        // Explosion is circular
        if transform.scale.x < explosionScale {
            transform.scale += explosionSpeed * deltaTime
            return false
        }
        guard let activeGameBoard = GameWorld.activeGameBoard else {
            fatalError("No active board")
        }
        activeGameBoard.removePeg(self)
        return true
    }

    func makeExplode() {
        guard let activeGameBoard = GameWorld.activeGameBoard else {
            fatalError("No active board")
        }
        exploded = true
        isTrigger = true
        bodyType = BodyType.kinematic
        // TODO: Nicer animation for explosion
        spriteContainer.sprite = peg.pegLitColor
        spriteContainer.opacity = 0.25
        activeGameBoard.addCoroutine(Coroutine(routine: explode, onCompleted: activeGameBoard.removeCoroutine))
    }

    override func onCollisionEnter(_ collision: Collision) {
        super.onCollisionEnter(collision)
        if !exploded && collision.rbB is CannonBall {
            makeExplode()
        }
    }

    override func onTriggerEnter(_ collision: Collision) {
        if !exploded && collision.rbB is BoomPeg {
            // Boom peg should explode as well when hit by the shockwave of another boom peg
            makeExplode()
            return
        }

        if let cannonBall = collision.rbB as? CannonBall {
            let direction = (cannonBall.transform.position - transform.position).normalize
            cannonBall.applyImpulse(direction * explosionImpulse / pow(transform.scale.x / initScale, 2))
            return
        }

        if let normalPeg = collision.rbB as? NormalPeg {
            normalPeg.makeFade()
            return
        }
    }
}
