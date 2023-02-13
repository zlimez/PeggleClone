//
//  Level.swift
//  Peggle
//
//  Created by James Chiu on 31/1/23.
//

import Foundation
import Combine

final class Levels: ObservableObject {
    // local cache
    @Published var levelTable: [String: DesignBoard] = [:]

    init() {
        let initValue: [String: DesignBoard] = [:]
        DataManager.load(filename: "levels.json", initValue: initValue) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let levelTable):
                self.levelTable = levelTable
            }
        }
    }

    // Copy is provided to prevent changes from being save without explicit request
    func loadLevel(_ levelName: String) -> DesignBoard? {
        levelTable[levelName]?.getCopy()
    }

    // Copy is being saved to prevent two boards from sharing same peg reference
    func saveLevel(levelName: String, updatedBoard: DesignBoard) {
        if levelName.isEmpty {
            return
        }

        levelTable[levelName] = updatedBoard.getCopy()
        DataManager.save(values: levelTable, filename: "levels.json") { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
}
