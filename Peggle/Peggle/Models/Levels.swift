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
    @Published var levelTable: [String: Board] = [:]

    init() {
        let initValue: [String: Board] = [:]
        DataManager.load(filename: "peggleLevels.json", initValue: initValue) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let levelTable):
                self.levelTable = levelTable
                for defaultLevel in DataManager.readDefault() {
                    self.levelTable[defaultLevel.key] = defaultLevel.value
                }
            }
        }
    }

    func loadLevel(_ levelName: String) -> Board? {
        levelTable[levelName]
    }

    // Copy is being saved to prevent two boards from sharing same peg reference
    func saveLevel(levelName: String, updatedBoard: Board) {
        if levelName.isEmpty {
            print("Empty level name cannot be saved")
            return
        }

        levelTable[levelName] = updatedBoard.getCopy()
        DataManager.save(values: levelTable, filename: "peggleLevels.json") { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
}
