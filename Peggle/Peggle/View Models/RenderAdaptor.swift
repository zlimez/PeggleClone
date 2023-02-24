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

    init() {
        self.gameWorld = GameWorld.getEmptyWorld()
        self.graphicObjects = []
        gameWorld.renderAdaptor = self
    }

    func setBackBoard(_ board: Board) {
        gameWorld.setNewBoard(board)
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
    }

    func configScene(_ worldDim: CGSize) {
        gameWorld.configWorldBounds(worldDim)
    }

    func fireCannonAt(_ aim: CGPoint) {
        gameWorld.fireCannonAt(Vector2(x: aim.x, y: aim.y))
    }
}
