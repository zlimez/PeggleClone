//
//  GameBoardVM.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

class RenderAdaptor: GameSystem, ObservableObject {
    var gameWorld: GameWorld
    @Published var graphicObjects: [WorldObjectVM]
    // UI elements
    @Published var numOfBalls: Int?
    @Published var score: Int?
    @Published var targetScore: Int?
    @Published var prettyTimeLeft: Int?
    @Published var civTally: (Int, Int)?
    @Published var gameEnded: Bool
    @Published var endState: String
    
    private var adaptScaleRatio: CGFloat = 0
    var viewDimDetermined = false
    var deviceGameViewSize = CGSize.zero

    init() {
        self.gameWorld = GameWorld.getEmptyWorld()
        self.graphicObjects = []
        self.endState = ""
        self.gameEnded = false
        self.score = nil
        self.numOfBalls = nil
        self.targetScore = nil
        self.prettyTimeLeft = nil
        self.civTally = nil
        gameWorld.onStepComplete.append(adaptScene)
        gameWorld.onEvaluationComplete.append(adaptPlayState)
    }

    // Third argument is to cater for the case where player sets the ball count
    func setBoardAndMode(board: Board, gameMode: String, ballCount: Int) {
        guard let selectedGameMode = ModeMapper.modeToGameAttachmentTable[gameMode] else {
            fatalError("UI enabled invalid mode selection")
        }

        if selectedGameMode.canEditBallCount {
            gameWorld.setNewBoard(board: board, gameMode: gameMode, startBallCount: ballCount)
        } else {
            gameWorld.setNewBoard(board: board, gameMode: gameMode)
        }
    }

    lazy var adaptScene: (any Collection<WorldObject>) -> Void = { [unowned self] (worldObjects: any Collection<WorldObject>) in
        graphicObjects.removeAll()
        for worldObject in worldObjects {
            if let graphicObject = worldObject as? Renderable {
                graphicObjects.append(WorldObjectVM(visibleObject: graphicObject, scaleFactor: adaptScaleRatio))
            } else {
                fatalError("World object without graphic object cannot be rendered")
            }
        }
    }

    lazy var adaptPlayState: () -> Void = { [unowned self] in
        endState = gameWorld.playState == PlayState.won ? "WON" : gameWorld.playState == PlayState.lost ? "LOST" : "IN PROGRESS"
        numOfBalls = gameWorld.ballCount
        score = gameWorld.currScore
        targetScore = gameWorld.scoreToBeat
        if let timeLeft = gameWorld.timeLeft {
            prettyTimeLeft = Int(ceil(timeLeft))
        }
        civTally = gameWorld.civDeath
        gameEnded = endState == "WON" || endState == "LOST"
    }

    func configScene(_ viewDim: CGSize) {
        adaptScaleRatio = min(viewDim.width / gameWorld.worldDim.width, viewDim.height / gameWorld.worldDim.height)
        viewDimDetermined = true
        deviceGameViewSize = CGSize(width: gameWorld.worldDim.width / adaptScaleRatio, height: gameWorld.worldDim.height / adaptScaleRatio)
    }

    func fireCannonAt(_ aim: CGPoint) {
        gameWorld.fireCannonAt(Vector2(x: aim.x, y: aim.y))
    }
}
