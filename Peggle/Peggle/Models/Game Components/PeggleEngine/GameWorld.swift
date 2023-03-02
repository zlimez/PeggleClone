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
    let pegRemovalTimeInterval: Double
    // If a peg is hit more than this number of times it might be trapping the ball,
    // and hence should be removed prematurely
    let pegRemovalHitCount: Int
    let flipTimeInterval: Double = 0.5

    // All game systems
    let physicsWorld: PhysicsWorld
    // Pegs that have been hit during this launch
    private var collidedPegBodies: Set<NormalPeg> = []
    private var allPegBodies: Set<PegRB> = []
    private var graphicObjects: Set<WorldObject> = []
    // For external gamesystems to register their responses
    var onBallHitPeg: [(PegRB) -> Void] = []
    var onPegRemoved: [(PegRB) -> Void] = []
    var onShotFinalized: [() -> Void] = []

    var onStepComplete: [(any Collection<WorldObject>) -> Void] = []
    var onEvaluationComplete: [() -> Void] = []

    // Contains information such as score, civilians killed etc. determined by game mode configurer
    var ballCounter = BallCounter()
    var timer = Timer()
    var score = Score()
    var targetScore = TargetScore()
    var civTally = CivTally()

    var playState = PlayState.none
    private var gameModeAttachment = ModeMapper.defaultMode

    let eventLoop: EventLoop
    private var coroutines: Set<Coroutine> = []
    var gameTime: Double {
        eventLoop.gameTime
    }

    // Game specific objects
    private var cannon: Cannon?
    // Include loid pegs
    var activeBallCount: Int = 0
    private var bucket: Bucket?
    let worldDim = CGSize(width: 820, height: 980)
    let worldCenter: Vector2

    static func getEmptyWorld() -> GameWorld {
        GameWorld()
    }

    init(preferredFrameRate: Float = 90, pegRemovalTimeInterval: Double = 2, pegRemovalHitCount: Int = 10) {
        self.physicsWorld = PhysicsWorld(gravity: PhysicsWorld.defaultGravity, scaleFactor: 75)
        self.eventLoop = EventLoop(preferredFrameRate: preferredFrameRate)
        self.pegRemovalTimeInterval = pegRemovalTimeInterval
        self.worldCenter = Vector2(x: worldDim.width / 2, y: worldDim.height / 2)
        self.pegRemovalHitCount = pegRemovalHitCount

        GameWorld.activeGameBoard = self
    }

    func exitGame() {
        eventLoop.stop()

        physicsWorld.removeAllBodies()
        graphicObjects.removeAll()
        collidedPegBodies.removeAll()
        allPegBodies.removeAll()

        coroutines.removeAll()

        onBallHitPeg.removeAll()
        onPegRemoved.removeAll()
        onStepComplete.removeAll()
        onShotFinalized.removeAll()
        onEvaluationComplete.removeAll()

        activeBallCount = 0
        playState = PlayState.none

        gameModeAttachment.reset()
    }

    func setNewBoard(board: Board, gameMode: String, startBallCount: Int? = nil) {
        if let modeAttachment = ModeMapper.modeToGameAttachmentTable[gameMode] {
            gameModeAttachment = modeAttachment
        } else {
            gameModeAttachment = ModeMapper.defaultMode
        }

        if let startBallCount = startBallCount {
            ballCounter.isActive = true
            ballCounter.ballCount = startBallCount
        }

        for peg in board.allPegs {
            let pegRbMaker = PegMapper.getPegRbMaker(peg.pegVariant)
            let pegMade = pegRbMaker(peg)
            addObject(pegMade)
        }

        gameModeAttachment.setUpWorld(gameWorld: self, pegBodies: allPegBodies)
        configWorldBounds()
    }

    // 820 x 980 standard world dimension
    private func configWorldBounds() {
        let newCannon = Cannon(cannonPosition: Vector2(x: worldCenter.x, y: 60), spawnOffset: 100)
        self.cannon = newCannon
        newCannon.onCannonFired.append(addCannonBall)
        graphicObjects.insert(newCannon)

        let bufferHeight: CGFloat = 100

        let wallThickness: CGFloat = 20
        // Set colliders along the top, left and right borders of the screen
        let topWall = Wall(
            dim: CGSize(width: worldDim.width, height: wallThickness),
            position: Vector2(x: worldCenter.x, y: -wallThickness / 2 - bufferHeight)
        )
        let rightWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height + 2 * bufferHeight),
            position: Vector2(x: worldDim.width + wallThickness / 2, y: worldCenter.y)
        )
        let leftWall = Wall(
            dim: CGSize(width: wallThickness, height: worldDim.height + 2 * bufferHeight),
            position: Vector2(x: -wallThickness / 2, y: worldCenter.y)
        )

        let ballRecycler = BallRecycler(
            dim: CGSize(width: worldDim.width, height: wallThickness),
            position: Vector2(x: worldCenter.x, y: worldDim.height + wallThickness / 2 + bufferHeight)
        )

        let bucket = Bucket(
            transform: Transform(Vector2(x: worldCenter.x, y: worldDim.height)),
            center: worldCenter.x,
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

    func addObject(_ pegRb: PegRB) {
        addObject(pegRb as RigidBody)
        allPegBodies.insert(pegRb)
    }

    func addObject(_ body: RigidBody) {
        addObject(body as WorldObject)
        physicsWorld.addBody(body)
    }

    func addObject(_ addedObject: WorldObject) {
        if addedObject is Renderable {
            graphicObjects.insert(addedObject)
        }
    }

    func removePeg(_ pegRb: PegRB) {
        physicsWorld.removeBody(pegRb)
        allPegBodies.remove(pegRb)
        graphicObjects.remove(pegRb)
        onPegRemoved.forEach { response in response(pegRb) }
        tryFinalizeShot()
    }

    func removePeg(_ normalPeg: NormalPeg) {
        let pegRb: PegRB = normalPeg
        collidedPegBodies.remove(normalPeg)
        removePeg(pegRb)
    }

    func queuePegRemoval(_ hitPegRb: NormalPeg) {
        collidedPegBodies.insert(hitPegRb)
    }

    func fadeCollidedPegs() {
        if activeBallCount > 0 {
            return
        }

        for hitPeg in collidedPegBodies {
            hitPeg.makeFade()
        }
    }

    func fireCannonAt(_ aim: Vector2) {
        if !ballCounter.hasBallLeft {
            return
        }

        cannon?.fireCannonAt(aim)
    }

    private lazy var addCannonBall: (CannonBall) -> Void = { [unowned self] (cannonBall: CannonBall) in
        addObject(cannonBall)
        activeBallCount += 1
        ballCounter.onBallFired(1)
    }

    func removeCannonBall(_ cannonBall: CannonBall) {
        physicsWorld.removeBody(cannonBall)
        graphicObjects.remove(cannonBall)
        activeBallCount -= 1

        // To proceed with score and ready cannon for next shot
        tryFinalizeShot()
    }

    func recycleBall() {
        ballCounter.onBallRecycled(1)
    }

    func tryFinalizeShot() {
        /// All pegs must be removed and the ball must exit the screen before cannon is ready again
        if !shotComplete {
            return
        }
        onShotFinalized.forEach { response in response() }
        cannon?.cannonReady = true
    }

    func shutBucket() {
        bucket?.shut()
    }

    func openBucket() {
        bucket?.open()
    }

    func flipPegs() {
        for pegBody in allPegBodies {
            if pegBody.bodyType == BodyType.stationary {
                addCoroutine(Coroutine(routine: pegBody.makeFlipRotator(worldCenter), onCompleted: removeCoroutine))
            }
        }
    }

    private func startSimulation() {
        playState = PlayState.inProgress
        eventLoop.start(step)
    }

    private func step(deltaTime: Double) {
        physicsWorld.step(deltaTime)

        // Exexute all coroutine
        for coroutine in coroutines {
            coroutine.execute(deltaTime)
        }

        timer.countDown(deltaTime)
        gameModeAttachment.evaluate(gameWorld: self, playState: &playState)
        for sceneAdaption in onStepComplete {
            sceneAdaption(graphicObjects)
        }

        for stateAdaption in onEvaluationComplete {
            stateAdaption()
        }
        if playState == PlayState.won || playState == PlayState.lost {
            exitGame()
        }
    }
}

extension GameWorld {
    // UI elements
    var ballCount: Int? {
        ballCounter.getBallCount()
    }
    var timeLeft: Double? {
        timer.getTime()
    }
    var currScore: Int? {
        score.getScore(gameModeAttachment)
    }
    var scoreToBeat: Int? {
        targetScore.getTargetScore(gameModeAttachment)
    }
    var civDeath: (Int, Int)? {
        civTally.getCivDeathTally(gameModeAttachment)
    }

    var shotComplete: Bool {
        activeBallCount == 0 && collidedPegBodies.isEmpty
    }
    
    func addBallToCount() {
        if !ballCounter.isActive {
            return
        }
        
        ballCounter.ballCount += 1
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
