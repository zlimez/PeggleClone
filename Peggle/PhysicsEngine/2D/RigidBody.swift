//
//  RigidBody.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

// All rigidbodies have a collider
// static rigidbodies for objects that require collider but does not move or can only be moved by
// dynamic rigidbodies for objects that moves based on force and velocity
class RigidBody: WorldObject {
    let isDynamic: Bool
    let material: Material
    var velocity: Vector2
    let mass: CGFloat
    let collider: Collider
    let isTrigger: Bool
    var collisionResponse: [(RigidBody) -> Void] = []
    
    init(isDynamic: Bool, material: Material, transform: Transform,  collider: Collider, isTrigger: Bool, mass: CGFloat) {
        self.isDynamic = isDynamic
        self.velocity = Vector2.zero
        self.collider = collider
        self.isTrigger = isTrigger
        if !isDynamic {
            print("Static bodies have mass and material restitution defaulted to 1 regardless of input")
            self.mass = 1
            self.material = Material.staticMaterial
        } else {
            self.mass = mass
            self.material = material
        }
        super.init(transform)
    }
    
    func onCollision(otherBody: RigidBody) {
        for response in collisionResponse {
            response(otherBody)
        }
    }
    
    func applyForce(force: Vector2, deltaTime: CGFloat) {
        if !isDynamic {
            fatalError("Cannot apply force on static body")
        }
        
        let acceleration = force / mass
        velocity = velocity + acceleration * deltaTime
    }
    
    func applyImpulse(_ impulse: Vector2) {
        if !isDynamic {
            fatalError("Cannot apply impulse on static body")
        }
        
        velocity = velocity + impulse / mass
    }
    
    func updatePosition(_ deltaTime: CGFloat) {
        if !isDynamic {
            fatalError("Cannot move rigidbody by velocity")
        }
        transform.position = transform.position + velocity * deltaTime
    }
    
    func moveTo(destination: Vector2) {
        transform.position = destination
    }
}
