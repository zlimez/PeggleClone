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
class RigidBody: WorldObject, Hashable, Identifiable {
    private static var bodyCounter = 0
    let id: Int
    let isDynamic: Bool
    let material: Material
    var velocity: Vector2
    let mass: CGFloat
    let collider: Collider
    let isTrigger: Bool
    var collisionEnter: [(Collision) -> Void]?
    var collisionExit: [() -> Void]?
    var triggerEnter: [(Collision) -> Void] = []
    var triggerExit: [() -> Void] = []

    static func resetCounter() {
        bodyCounter = 0
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
        self.id = RigidBody.bodyCounter
        self.isDynamic = isDynamic
        self.velocity = initVelocity
        self.collider = collider
        self.isTrigger = isTrigger

        if !isTrigger {
            collisionEnter = []
            collisionExit = []
        }

        if !isDynamic {
            print("Static bodies have mass and material restitution defaulted to 1 regardless of input")
            self.mass = 1
            self.material = Material.staticMaterial
        } else {
            self.mass = mass
            self.material = material
        }

        RigidBody.bodyCounter += 1
        super.init(transform)
    }

    func onCollisionEnter(_ collision: Collision) {
        guard let responses = collisionEnter else {
            fatalError("Collision enter event invoked on isTrigger body")
        }

        for response in responses {
            response(collision)
        }
    }

    func onCollisionExit() {
        guard let responses = collisionExit else {
            fatalError("Collision exit event invoked on isTrigger body")
        }

        for response in responses {
            response()
        }
    }

    // Keeps getting invoked when another rb enters the trigger
    // To differentiate between start and stay must compare frame by frame
    // which triggers ended
    func onTrigger(_ collision: Collision) {
        for response in triggerEnter {
            response(collision)
        }
    }

    func onTriggerExit(_ otherBody: RigidBody) {
        for response in triggerExit {
            response()
        }
    }

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

    func moveTo(destination: Vector2) {
        transform.position = destination
    }

    static func == (lhs: RigidBody, rhs: RigidBody) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
