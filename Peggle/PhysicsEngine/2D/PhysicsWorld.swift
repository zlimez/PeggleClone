//
//  PhysicsWorld.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

// Assumes one medium per world
// Units are based in meter and seconds should be scaled accordingly
// to the game dimensions for visible effect of env factors
class PhysicsWorld {
    static let defaultGravity = Vector2(x: 0, y: 9.81)
    static let defaultDrag: CGFloat = 0
    private let scaleFactor: CGFloat
    private let gravity: Vector2
    private let drag: CGFloat
    // 30fps
    // private let fixedDeltaTime: CGFloat = 1 / 30
    private var bodies: [RigidBody] = []
    private var lastCollidingBodies: Set<RigidBody> = []
    private var currCollidingBodies: Set<RigidBody> = []

    init(
        gravity: Vector2 = PhysicsWorld.defaultGravity,
        drag: CGFloat = PhysicsWorld.defaultDrag,
        scaleFactor: CGFloat = 1
    ) {
        self.gravity = gravity
        self.drag = drag
        self.scaleFactor = scaleFactor
    }

    func getBodies() -> [RigidBody] {
        bodies
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

    func removeAllBodies() {
        bodies.removeAll()
        lastCollidingBodies.removeAll()
        currCollidingBodies.removeAll()
    }

    func step(_ deltaTime: CGFloat) {
        applyGravity(deltaTime)
        applyDrag(deltaTime)
        resolveCollisions(getCollisions())
        updateBodies(deltaTime)
    }

    func getCollisions() -> ([Collision], [Collision]) {
        var collisions: [Collision] = []
        var triggers: [Collision] = []
        for i in 0..<bodies.count {
            let rbA = bodies[i]
            for j in (i + 1)..<bodies.count {
                let rbB = bodies[j]

                if rbA.bodyType == BodyType.stationary && rbB.bodyType == BodyType.stationary {
                    continue
                }

                let cp = rbA.collider.testCollision(
                    transform: rbA.transform,
                    otherCollider: rbB.collider,
                    otherTransform: rbB.transform
                )

                if cp.hasCollision {
                    currCollidingBodies.insert(rbA)
                    currCollidingBodies.insert(rbB)

                    let collision = Collision(rbA: rbA, rbB: rbB, contact: cp)
                    if rbA.isTrigger || rbB.isTrigger {
                        triggers.append(collision)
                        continue
                    }

                    collisions.append(collision)
                }
            }
        }

        return (collisions, triggers)
    }

    func resolveCollisions(_ collisionAndTriggers: ([Collision], [Collision])) {
        let collisions = collisionAndTriggers.0
        let triggers = collisionAndTriggers.1

        for collision in collisions {
            PositionSolver.solve(collision)
            ImpulseSolver.solve(collision)
        }

        // Invoke all listener responses for collision event
        // Assumes collision detection and resolution is rapid enough such that collision is resolve in the next frame
        for collision in collisions + triggers {
            collision.rbA.onCollisionOrTrigger(collision)
            collision.rbB.onCollisionOrTrigger(collision.reverse)
        }

        currCollidingBodies.union(lastCollidingBodies).forEach { body in
            body.processEndedCollisionsOrTriggers()
            body.moveCollidingBuffers()
        }

        lastCollidingBodies = currCollidingBodies
        currCollidingBodies.removeAll()
    }

    func applyGravity(_ deltaTime: CGFloat) {
        for body in bodies {
            if !body.isDynamic {
                continue
            }

            body.applyForce(force: gravity * body.mass * scaleFactor, deltaTime: deltaTime)
        }
    }

    func applyDrag(_ deltaTime: CGFloat) {
        for body in bodies {
            if !body.isDynamic {
                continue
            }

            body.applyForce(force: -body.velocity * drag * scaleFactor, deltaTime: deltaTime)
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
