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

    init() {
        self.gameWorld = GameWorld.getEmptyWorld()
        self.graphicObjects = []
        gameWorld.onStepCompleted.append(adaptScene)
    }

    func setBoardAndMode(board: Board, gameMode: String) {
        gameWorld.setNewBoard(board: board, gameMode: gameMode)
    }

    func adaptScene(_ worldObjects: any Collection<WorldObject>) {
        graphicObjects.removeAll()
        for worldObject in worldObjects {
            if let graphicObject = worldObject as? Renderable {
                graphicObjects.append(WorldObjectVM(graphicObject))
            } else {
                fatalError("World object without graphic object cannot be rendered")
            }
        }
        numOfBalls = gameWorld.ballCount
        score = gameWorld.currScore
        targetScore = gameWorld.scoreToBeat
        if let timeLeft = gameWorld.timeLeft {
            prettyTimeLeft = Int(ceil(timeLeft))
        }
        civTally = gameWorld.civDeath
    }

    func configScene(_ worldDim: CGSize) {
        gameWorld.configWorldBounds(worldDim)
    }

    func fireCannonAt(_ aim: CGPoint) {
        gameWorld.fireCannonAt(Vector2(x: aim.x, y: aim.y))
    }
}
