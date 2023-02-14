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
    
    init(cannonPosition: Vector2, spawnOffset: CGFloat, cannonSpeed: CGFloat = 150) {
        self.cannonPosition = cannonPosition
        self.spawnOffset = spawnOffset
        self.cannonSpeed = cannonSpeed
    }
    
    func fireCannonAt(_ aim: Vector2) {
        let direction = (aim - cannonPosition).normalize
        let initVelocity = direction * cannonSpeed
        let ballSpawnPoint = Transform(cannonPosition + direction * spawnOffset)
        let cannonBall = CannonBall(launchTransform: ballSpawnPoint, initVelocity: initVelocity)
        
        for response in onCannonFired {
            response(cannonBall)
        }
    }
}

class CannonBall: RigidBody {
    static let defaultRadius: CGFloat = 30
    static let defaultMass: CGFloat = 10
    static let defaultMaterial = Material(restitution: 0.5)
    
    init(
        launchTransform: Transform,
        initVelocity: Vector2,
        radius: CGFloat = CannonBall.defaultRadius,
        mass: CGFloat = CannonBall.defaultMass,
        material: Material = CannonBall.defaultMaterial
    ) {
        super.init(
            isDynamic: true,
            material: material,
            collider: CircleCollider(radius),
            transform: launchTransform,
            mass: mass,
            initVelocity: initVelocity
        )
    }
}
