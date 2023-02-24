//
//  GameWorld.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation
import QuartzCore

class GameWorld {
    static var activeGameBoard: GameWorld?
    var worldBoundsInitialized = false
    let pegRemovalHitCount: Int
    let pegRemovalTimeInterval: Double
    let physicsWorld: PhysicsWorld
    let eventLoop: EventLoop
    var cannon: Cannon?
    var worldDim: CGSize?
    var renderAdaptor: RenderAdaptor?
    var gameTime: Double {
        eventLoop.gameTime
    }
    // Pegs that have been hit during this launch
    var collidedPegBodies: Set<PegRigidBody> = []
    var coroutines: Set<Coroutine> = []

    static func getEmptyWorld() -> GameWorld {
        GameWorld()
    }

    init(preferredFrameRate: Float = 90, pegRemovalHitCount: Int = 5, pegRemovalTimeInterval: Double = 2) {
        self.physicsWorld = PhysicsWorld(gravity: PhysicsWorld.defaultGravity, scaleFactor: 75)
        self.eventLoop = EventLoop(preferredFrameRate: preferredFrameRate)
        self.pegRemovalHitCount = pegRemovalHitCount
        self.pegRemovalTimeInterval = pegRemovalTimeInterval

        GameWorld.activeGameBoard = self
    }

    func setNewBoard(_ board: Board) {
        print("setting new board")
        physicsWorld.removeAllBodies()
        for peg in board.allPegs {
            let pegRb = PegRigidBody(peg)
            physicsWorld.addBody(pegRb)
        }

        worldBoundsInitialized = false
    }

    func configWorldBounds(_ worldDim: CGSize) {
        self.worldDim = worldDim
        self.cannon = Cannon(cannonPosition: Vector2(x: worldDim.width / 2, y: 60), spawnOffset: 100)
        cannon?.onCannonFired.append(addCannonBall)
        let bufferHeight: CGFloat = 100

        let wallThickness: CGFloat = 20
        // Set colliders along the top, left and right borders of the screen
        let topWall = Wall(
            dim: CGSize(width: worldDim.width, height: wallThickness),
            position: Vector2(x: worldDim.width / 2, y: -wallThickness / 2)
        )
        let rightWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height + bufferHeight),
            position: Vector2(x: worldDim.width + wallThickness / 2, y: (worldDim.height + bufferHeight) / 2)
        )
        let leftWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height + bufferHeight),
            position: Vector2(x: -wallThickness / 2, y: (worldDim.height + bufferHeight) / 2)
        )

        let ballRecycler = BallRecycler(
            dim: CGSize(width: worldDim.width, height: wallThickness),
            position: Vector2(x: worldDim.width / 2, y: worldDim.height + wallThickness / 2 + bufferHeight)
        )

        physicsWorld.addBody(topWall)
        physicsWorld.addBody(rightWall)
        physicsWorld.addBody(leftWall)
        physicsWorld.addBody(ballRecycler)

        // After all the bounds are initialized then start simulation
        print("Starting physics simulation")
        startSimulation()
    }

    func fireCannonAt(_ aim: Vector2) {
        cannon?.fireCannonAt(aim)
    }

    func addCoroutine(_ routine: Coroutine) {
        coroutines.insert(routine)
    }

    func removeCoroutine(_ routine: Coroutine) {
        coroutines.remove(routine)
    }

    func removePeg(_ pegRb: PegRigidBody) {
        physicsWorld.removeBody(pegRb)
        // To prevent duplicate removal when cannon exits screen
        collidedPegBodies.remove(pegRb)
    }

    func fadeCollidedPegs() {
        for hitPeg in collidedPegBodies {
            self.addCoroutine(Coroutine(routine: hitPeg.fade, onCompleted: removeCoroutine))
        }
        collidedPegBodies.removeAll()
    }

    func removeCannonBall(_ cannonBall: RigidBody) {
        if !(cannonBall is CannonBall) {
            fatalError("Removing non-cannon ball body in removeCannonBall function")
        }

        cannon?.cannonReady = true
        physicsWorld.removeBody(cannonBall)
    }

    func queuePegRemoval(_ hitPegRb: PegRigidBody) {
        collidedPegBodies.insert(hitPegRb)
    }

    private func addCannonBall(cannonBall: CannonBall) {
        physicsWorld.addBody(cannonBall)
    }

    private func startSimulation() {
        eventLoop.startLoop(step)
    }

    private func step(deltaTime: Double) {
        physicsWorld.step(deltaTime)

        // Exexute all coroutine
        for coroutine in coroutines {
            coroutine.execute(deltaTime)
        }
        // Ask renderer to render scene
        guard var renderAdaptor = renderAdaptor else {
            return
        }

        renderAdaptor.adaptScene(physicsWorld.getBodies())
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
