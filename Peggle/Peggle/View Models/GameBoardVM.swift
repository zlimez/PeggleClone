//
//  GameBoardVM.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

class GameBoardVM: RenderAdaptor, ObservableObject {
    var gameWorld: GameWorld
    @Published var bodyVMs: [RigidBodyVM]

    init() {
        self.gameWorld = GameWorld.getEmptyWorld()
        self.bodyVMs = []
        gameWorld.renderAdaptor = self
    }

    func setBackBoard(_ board: Board) {
        gameWorld.setNewBoard(board)
    }

    func adaptScene(_ bodies: [RigidBody]) {
        bodyVMs.removeAll()
        for body in bodies {
            if let visibleBody = body as? VisibleRigidBody {
                bodyVMs.append(RigidBodyVM(visibleBody))
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
