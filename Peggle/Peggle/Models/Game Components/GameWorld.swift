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
    let pegRemovalTimeInterval: Double

    // All game systems
    let physicsWorld: PhysicsWorld
    // Pegs that have been hit during this launch
    private var collidedPegBodies: Set<NormalPeg> = []
    var ballExit = false

    var renderAdaptor: RenderAdaptor?
    var graphicObjects: Set<WorldObject> = []

    private var scoreSystem: ScoreSystem

    let eventLoop: EventLoop
    private var coroutines: Set<Coroutine> = []
    var gameTime: Double {
        eventLoop.gameTime
    }

    // Game specific objects
    private var cannon: Cannon?
    private var bucket: Bucket?
    var numOfBalls: Int = 0
    var worldDim: CGSize?

    static func getEmptyWorld() -> GameWorld {
        GameWorld()
    }

    init(preferredFrameRate: Float = 90, pegRemovalTimeInterval: Double = 2) {
        self.physicsWorld = PhysicsWorld(gravity: PhysicsWorld.defaultGravity, scaleFactor: 75)
        self.eventLoop = EventLoop(preferredFrameRate: preferredFrameRate)
        self.pegRemovalTimeInterval = pegRemovalTimeInterval
        // TODO: Change the stub
        self.scoreSystem = BaseScoreSystem()

        GameWorld.activeGameBoard = self
    }

    func getScore() -> Int {
        scoreSystem.score
    }

    func setNewBoard(_ board: Board) {
        print("setting new board")
        // TODO: Move these recycling functions to when the game ends
        physicsWorld.removeAllBodies()
        graphicObjects.removeAll()
        coroutines.removeAll()
        collidedPegBodies.removeAll()
        scoreSystem.reset()

        for peg in board.allPegs {
            guard let pegRbMaker = PegMapper.pegVariantToPegRbTable[peg.pegVariant] else {
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
            position: Vector2(x: worldDim.width / 2, y: -wallThickness / 2 - bufferHeight)
        )
        let rightWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height + 2 * bufferHeight),
            position: Vector2(x: worldDim.width + wallThickness / 2, y: worldDim.height / 2)
        )
        let leftWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height + 2 * bufferHeight),
            position: Vector2(x: -wallThickness / 2, y: worldDim.height / 2)
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
        self.bucket = bucket

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
        scoreSystem.updateBaseScore(pegRb)
        // To prevent duplicate removal when cannon exits screen
        if let normalPeg = pegRb as? NormalPeg {
            collidedPegBodies.remove(normalPeg)
            tryFinalizeShot()
        }
    }

    func queuePegRemoval(_ hitPegRb: NormalPeg) {
        collidedPegBodies.insert(hitPegRb)
    }

    func fadeCollidedPegs() {
        for hitPeg in collidedPegBodies {
            hitPeg.makeFade()
        }
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

    func removeCannonBall(_ cannonBall: CannonBall) {
        physicsWorld.removeBody(cannonBall)
        graphicObjects.remove(cannonBall)
        ballExit = true

        // To proceed with score and ready cannon for next shot
        if collidedPegBodies.isEmpty {
            tryFinalizeShot()
        }
    }

    func tryFinalizeShot() {
        /// All pegs must be removed and the ball must exit the screen before cannon is ready again
        if !ballExit || !collidedPegBodies.isEmpty {
            return
        }

        scoreSystem.updateScore()
        cannon?.cannonReady = true
    }

    func shutBucket() {
        bucket?.shut()
    }

    func openBucket() {
        bucket?.open()
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
            bodyType: BodyType.stationary,
            material: Material.staticMaterial,
            collider: BoxCollider(halfWidth: dim.width / 2, halfHeight: dim.height / 2),
            transform: Transform(position)
        )
    }
}
