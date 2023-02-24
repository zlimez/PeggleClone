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
    private static let defaultStaticMass: CGFloat = 10
    let isDynamic: Bool
    let material: Material
    var velocity: Vector2
    let mass: CGFloat
    let collider: Collider
    var isTrigger: Bool
    private var lastCollidingBodies: [RigidBody: Collision]
    private var currCollidingBodies: [RigidBody: Collision]

    var momentum: Vector2 {
        velocity * mass
    }

    init(
        isDynamic: Bool,
        material: Material,
        collider: Collider,
        transform: Transform = Transform.standard,
        mass: CGFloat = 1,
        initVelocity: Vector2 = Vector2.zero,
        isTrigger: Bool = false
    ) {
        self.isDynamic = isDynamic
        self.velocity = initVelocity
        self.collider = collider
        self.isTrigger = isTrigger
        self.lastCollidingBodies = [:]
        self.currCollidingBodies = [:]

        if !isDynamic {
            self.mass = 10
            self.material = Material.staticMaterial
        } else {
            self.mass = mass
            self.material = material
        }

        super.init(transform)
    }

    func moveCollidingBuffers() {
        lastCollidingBodies = currCollidingBodies
        currCollidingBodies.removeAll()
    }

    func onCollisionOrTrigger(_ collision: Collision) {
        if lastCollidingBodies[collision.rbB] == nil {
            if isTrigger || collision.rbB.isTrigger {
                onTriggerEnter(collision)
            } else {
                onCollisionEnter(collision)
            }
        } else {
            if isTrigger || collision.rbB.isTrigger {
                onTriggerStay(collision)
            } else {
                onCollisionStay(collision)
            }
        }

        currCollidingBodies[collision.rbB] = collision
    }

    func processEndedCollisionsOrTriggers() {
        let endedCollisions = lastCollidingBodies.filter { currCollidingBodies[$0.key] == nil }
        for bodyCollision in endedCollisions {
            if isTrigger || bodyCollision.key.isTrigger {
                onTriggerExit(bodyCollision.value)
            } else {
                onCollisionExit(bodyCollision.value)
            }
        }
    }

    func onCollisionEnter(_ collision: Collision) {
        if isTrigger {
            fatalError("Collision enter event invoked on isTrigger body")
        }
    }

    func onCollisionExit(_ collision: Collision) {
        if isTrigger {
            fatalError("Collision exit event invoked on isTrigger body")
        }
    }

    func onCollisionStay(_ collision: Collision) {}
    func onTriggerEnter(_ collision: Collision) {}
    func onTriggerStay(_ collision: Collision) {}
    func onTriggerExit(_ collision: Collision) {}

    func applyForce(force: Vector2, deltaTime: CGFloat) {
        if !isDynamic {
            fatalError("Cannot apply force on static body")
        }

        let acceleration = force / mass
        velocity += acceleration * deltaTime
    }

    func applyImpulse(_ impulse: Vector2) {
        if !isDynamic {
            fatalError("Cannot apply impulse on static body")
        }

        velocity += impulse / mass
    }

    func updatePosition(_ deltaTime: CGFloat) {
        if !isDynamic {
            fatalError("Cannot move rigidbody by velocity")
        }
        transform.position += velocity * deltaTime
    }

    func move(_ displacement: Vector2) {
        transform.position += displacement
    }
}
