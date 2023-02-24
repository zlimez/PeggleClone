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

    // All game systems
    let physicsWorld: PhysicsWorld
    // Pegs that have been hit during this launch
    var collidedPegBodies: Set<HostilePeg> = []

    var renderAdaptor: RenderAdaptor?
    var graphicObjects: Set<WorldObject> = []
    let eventLoop: EventLoop
    var coroutines: Set<Coroutine> = []
    var gameTime: Double {
        eventLoop.gameTime
    }

    // Game specific objects
    var cannon: Cannon?
    var numOfBalls: Int = 0
    var worldDim: CGSize?

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
        // TODO: Move these recycling functions to when the game ends
        physicsWorld.removeAllBodies()
        graphicObjects.removeAll()
        coroutines.removeAll()
        collidedPegBodies.removeAll()

        for peg in board.allPegs {
            guard let pegRbMaker = PegMapper.pegToPegRbTable[peg.pegVariant] else {
                fatalError("Palette does not contain this saved peg")
            }
            addObject(pegRbMaker(peg))
        }

        setNumOfBalls()
        worldBoundsInitialized = false
    }

    func setNumOfBalls() {
        // TODO: Make numOfBalls given a heuristic
        numOfBalls = 10
    }

    func configWorldBounds(_ worldDim: CGSize) {
        self.worldDim = worldDim
        self.cannon = Cannon(cannonPosition: Vector2(x: worldDim.width / 2, y: 60), spawnOffset: 100)

        guard let cannon = self.cannon else {
            fatalError("Cannon not assigned")
        }
        cannon.onCannonFired.append(addCannonBall)
        graphicObjects.insert(cannon)

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

        let bucket = Bucket(
            transform: Transform(Vector2(x: worldDim.width / 2, y: worldDim.height)),
            center: worldDim.width / 2,
            leftEnd: 0,
            rightEnd: worldDim.width - 60
        )

        addObject(bucket)
        addObject(topWall)
        addObject(rightWall)
        addObject(leftWall)
        addObject(ballRecycler)

        // After all the bounds are initialized then start simulation
        print("Starting physics simulation")
        startSimulation()
    }

    func addCoroutine(_ routine: Coroutine) {
        coroutines.insert(routine)
    }

    func removeCoroutine(_ routine: Coroutine) {
        coroutines.remove(routine)
    }

    func addObject(_ addedObject: WorldObject) {
        if addedObject is Renderable {
            graphicObjects.insert(addedObject)
        }

        if let addedBody = addedObject as? RigidBody {
            physicsWorld.addBody(addedBody)
        }
    }

    func removePeg(_ pegRb: PegRB) {
        physicsWorld.removeBody(pegRb)
        graphicObjects.remove(pegRb)
        // To prevent duplicate removal when cannon exits screen
        if let hostilePeg = pegRb as? HostilePeg {
            collidedPegBodies.remove(hostilePeg)
        }
    }

    func queuePegRemoval(_ hitPegRb: HostilePeg) {
        collidedPegBodies.insert(hitPegRb)
    }

    func fadeCollidedPegs() {
        for hitPeg in collidedPegBodies {
            hitPeg.makeFade()
        }
        collidedPegBodies.removeAll()
    }

    func fireCannonAt(_ aim: Vector2) {
        if numOfBalls <= 0 {
            return
        }

        cannon?.fireCannonAt(aim)
    }

    private func addCannonBall(cannonBall: CannonBall) {
        addObject(cannonBall)
        numOfBalls -= 1
    }

    func removeCannonBall(_ cannonBall: RigidBody) {
        if !(cannonBall is CannonBall) {
            fatalError("Removing non-cannon ball body in removeCannonBall function")
        }

        cannon?.cannonReady = true
        physicsWorld.removeBody(cannonBall)
        graphicObjects.remove(cannonBall)
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
        guard let renderAdaptor = renderAdaptor else {
            return
        }

        renderAdaptor.adaptScene(graphicObjects)
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
