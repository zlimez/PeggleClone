//
//  GameBoard.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation
import QuartzCore

class GameBoard {
    static var activeGameBoard: GameBoard?
    let preferredFrameRate: Int
    let pegRemovalThreshold: Int
    let physicsWorld: PhysicsWorld
    var cannon: Cannon?
    var worldDim: CGSize?
    var activeDisplayLink: CADisplayLink?
    var gameTime: Double {
        guard let displayLink = activeDisplayLink else {
            return 0
        }

        return displayLink.timestamp
    }
    // Pegs that have been hit during this launch
    var collidedPegBodies: Set<RigidBody> = []

    init(board: Board, preferredFrameRate: Int = 30, pegRemovalThreshold: Int = 5) {
        self.preferredFrameRate = preferredFrameRate
        self.physicsWorld = PhysicsWorld()
        self.pegRemovalThreshold = pegRemovalThreshold

        for peg in board.allPegs {
            let pegRb = PegRigidBody(peg)
            physicsWorld.addBody(pegRb)
            pegRb.collisionEnter?.append(queuePegRemoval)
        }

        GameBoard.activeGameBoard = self
    }

    func configWorldBounds(_ worldDim: CGSize) {
        self.worldDim = worldDim
        self.cannon = Cannon(cannonPosition: Vector2(x: worldDim.width / 2, y: 60), spawnOffset: 100)
        cannon?.onCannonFired.append(addCannonBall)

        let wallThickness: CGFloat = 20
        // Set colliders along the top, left and right borders of the screen
        let topWall = Wall(
            dim: CGSize(width: worldDim.width, height: wallThickness),
            position: Vector2(x: worldDim.width / 2, y: -wallThickness / 2)
        )
        let rightWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height),
            position: Vector2(x: worldDim.width + wallThickness / 2, y: worldDim.height / 2)
        )
        let leftWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height),
            position: Vector2(x: -wallThickness / 2, y: worldDim.height / 2)
        )

        let ballRecycler = BallRecycler(
            dim: CGSize(width: worldDim.width, height: wallThickness),
            position: Vector2(x: worldDim.width / 2, y: worldDim.height + wallThickness / 2)
        )

        physicsWorld.addBody(topWall)
        physicsWorld.addBody(rightWall)
        physicsWorld.addBody(leftWall)
        physicsWorld.addBody(ballRecycler)

        // After all the bounds are initialized then start simulation
        startSimulation()
    }

    func removePeg(_ pegRb: PegRigidBody) {
        physicsWorld.removeBody(pegRb)
    }

    func removeCollidedPegs() {
        physicsWorld.removeBodies(collidedPegBodies)
        collidedPegBodies.removeAll()
    }

    func removeCannonBall(_ cannonBall: RigidBody) {
        if !(cannonBall is CannonBall) {
            fatalError("Removing non-cannon ball body in removeCannonBall function")
        }
  
        physicsWorld.removeBody(cannonBall)
    }

    private func queuePegRemoval(collision: Collision) {
        if collidedPegBodies.contains(collision.rbA) {
            return
        }
  
        if collision.rbB is CannonBall {
            collidedPegBodies.insert(collision.rbA)
        }
    }

    private func addCannonBall(cannonBall: CannonBall) {
        physicsWorld.addBody(cannonBall)
    }

    private func startSimulation() {
        activeDisplayLink?.invalidate()
        activeDisplayLink = CADisplayLink(target: self, selector: #selector(stepAdapter))
        activeDisplayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 20, maximum: 60, __preferred: 30)

        activeDisplayLink?.add(to: .current, forMode: .default)
    }

    @objc func stepAdapter() {
        guard let displayLink = activeDisplayLink else {
            fatalError("Physics step invoked before display link is created")
        }
        physicsWorld.step(displayLink.targetTimestamp - displayLink.timestamp)
    }
}

class Wall: RigidBody {
    init(dim: CGSize, position: Vector2) {
        super.init(
            isDynamic: false,
            material: Material.staticMaterial,
            collider: BoxCollider(halfWidth: dim.width / 2, halfHeight: dim.height / 2),
            transform: Transform(position)
        )
    }
}
