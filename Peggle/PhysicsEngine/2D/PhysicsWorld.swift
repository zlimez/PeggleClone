//
//  PhysicsWorld.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

// Assumes one medium per world
class PhysicsWorld {
    static let defaultGravity = Vector2(x: 0, y: 9.81)
    static let defaultDrag: CGFloat = 0
    private let gravity: Vector2
    private let drag: CGFloat
    // 30fps
    // private let fixedDeltaTime: CGFloat = 1 / 30
    private var bodies: [RigidBody] = []
    private let impulseSolver = ImpulseSolver()
    // private var collidingBodies: Set<RigidBody> = []
    // private var triggeringBodies: Set<RigidBody> = []

    init(gravity: Vector2 = PhysicsWorld.defaultGravity, drag: CGFloat = PhysicsWorld.defaultDrag) {
        self.gravity = gravity
        self.drag = drag
    }

    func addBody(_ addedBody: RigidBody) {
        bodies.append(addedBody)
    }

    func removeBody(_ removedBody: RigidBody) {
        bodies = bodies.filter { $0 != removedBody }
    }
    
    func removeBodies(_ removedBodies: Set<RigidBody>) {
        bodies = bodies.filter { !removedBodies.contains($0) }
    }

    func step(_ deltaTime: CGFloat) {
        applyGravity(deltaTime)
        applyDrag(deltaTime)
        resolveCollisions()
        updateBodies(deltaTime)
    }

    func resolveCollisions() {
        var collisions: [Collision] = []
        var triggers: [Collision] = []
        for i in 0..<bodies.count {
            let rbA = bodies[i]
            for j in (i + 1)..<bodies.count {
                let rbB = bodies[j]
                let cp = rbA.collider.testCollision(
                    transform: rbA.transform,
                    otherCollider: rbB.collider,
                    otherTransform: rbB.transform
                )

                if cp.hasCollision {
                    let collision = Collision(rbA: rbA, rbB: rbB, contact: cp)
                    if rbA.isTrigger || rbB.isTrigger {
                        triggers.append(collision)
                        continue
                    }

                    collisions.append(collision)
                }
            }
        }

        for collision in collisions {
            impulseSolver.solve(collision)
        }

        // Invoke all listener responses for collision event
        // Assumes collision detection and resolution is rapid enough such that collision is resolve in the next frame
        for collision in collisions {
            collision.rbA.onCollisionEnter(collision)
            collision.rbB.onCollisionEnter(collision.reverse)
        }
        
        for trigger in triggers {
            trigger.rbA.onCollisionEnter(trigger)
            trigger.rbB.onCollisionEnter(trigger.reverse)
        }
    }

    func applyGravity(_ deltaTime: CGFloat) {
        for body in bodies {
            if !body.isDynamic {
                continue
            }

            body.applyForce(force: gravity * body.mass, deltaTime: deltaTime)
        }
    }

    func applyDrag(_ deltaTime: CGFloat) {
        for body in bodies {
            if !body.isDynamic {
                continue
            }

            body.applyForce(force: -body.velocity * drag, deltaTime: deltaTime)
        }
    }

    func updateBodies(_ deltaTime: CGFloat) {
        for body in bodies {
            if !body.isDynamic {
                continue
            }

            body.updatePosition(deltaTime)
        }
    }
}
