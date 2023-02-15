//
//  Cannon.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

class Cannon {
    let cannonPosition: Vector2
    let cannonSpeed: CGFloat
    // Relative to cannon position facing downwards
    let spawnOffset: CGFloat
    var onCannonFired: [(CannonBall) -> Void] = []
    var cannonReady = true

    init(cannonPosition: Vector2, spawnOffset: CGFloat, cannonSpeed: CGFloat = 600) {
        self.cannonPosition = cannonPosition
        self.spawnOffset = spawnOffset
        self.cannonSpeed = cannonSpeed
    }

    func fireCannonAt(_ aim: Vector2) {
        if !cannonReady {
            return
        }

        cannonReady = false
        let direction = (aim - cannonPosition).normalize
        // Cannon should not fire downwards
        if direction.y < 0 {
            return
        }

        let initVelocity = direction * cannonSpeed
        let ballSpawnPoint = Transform(cannonPosition + direction * spawnOffset)
        let cannonBall = CannonBall(launchTransform: ballSpawnPoint, initVelocity: initVelocity)

        for response in onCannonFired {
            response(cannonBall)
        }
    }
}

class CannonBall: VisibleRigidBody {
    static let defaultRadius: CGFloat = 30
    static let defaultMass: CGFloat = 1
    static let defaultMaterial = Material(restitution: 0.75)

    init(
        launchTransform: Transform,
        initVelocity: Vector2,
        radius: CGFloat = CannonBall.defaultRadius,
        mass: CGFloat = CannonBall.defaultMass,
        material: Material = CannonBall.defaultMaterial
    ) {
        let spriteContainer = SpriteContainer(
            sprite: "ball",
            unitWidth: radius * 2,
            unitHeight: radius * 2
        )
        super.init(
            isDynamic: true,
            material: material,
            collider: CircleCollider(radius),
            spriteContainer: spriteContainer,
            transform: launchTransform,
            mass: mass,
            initVelocity: initVelocity
        )
    }
}
