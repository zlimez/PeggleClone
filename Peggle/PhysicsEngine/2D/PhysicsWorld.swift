//
//  PhysicsWorld.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

// Assumes one medium per world
class PhysicsWorld {
    private let gravity: Vector2
    private let dragFactor: CGFloat
    // 30fps
//    private let fixedDeltaTime: CGFloat = 1 / 30
    private var deltaTime: CGFloat
    private var bodies: [RigidBody]
    private let impulseSolver: ImpulseSolver = ImpulseSolver()
    
    init(gravity: Vector2, dragFactor: CGFloat, deltaTime: CGFloat) {
        self.gravity = gravity
        self.deltaTime = deltaTime
        self.dragFactor = dragFactor
        self.bodies = []
    }
    
    func addBody(_ addedBody: RigidBody) {
        bodies.append(addedBody)
    }
    
    func removeBody(_ removedBody: RigidBody) {
        bodies = bodies.filter{ $0 !== removedBody }
    }
    
    func step() {
        applyGravity()
        resolveCollisions()
        updateBodies()
    }
    
    func resolveCollisions() {
        var collisions: [Collision] = []
        var triggers: [Collision] = []
        for i in 0..<bodies.count {
            let rbA = bodies[i]
            for j in (i + 1)..<bodies.count {
                let rbB = bodies[j]
                let cp = rbA.collider.testCollision(transform: rbA.transform, otherCollider: rbB.collider, otherTransform: rbB.transform)
                
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
        for collision in collisions {
            collision.rbA.onCollision(otherBody: collision.rbB)
            collision.rbB.onCollision(otherBody: collision.rbA)
        }
    }
    
    func applyGravity() {
        for body in bodies {
            if !body.isDynamic {
                continue
            }
            
            body.applyForce(force: gravity * body.mass, deltaTime: deltaTime)
        }
    }
    
    func updateBodies() {
        for body in bodies {
            if !body.isDynamic {
                continue
            }
            
            body.updatePosition(deltaTime)
        }
    }
}
