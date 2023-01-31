//
//  Level.swift
//  Peggle
//
//  Created by James Chiu on 31/1/23.
//

import Foundation
import Combine

final class Levels: ObservableObject {
    @Published var levelTable: [String: Board] = DataManager.loadLevels()
    
    func loadLevel(_ levelName: String) -> Board? {
        return levelTable[levelName]?.getCopy()
    }
    
    func saveLevel(levelName: String, updatedBoard: Board) {
        levelTable[levelName] = updatedBoard
        do {
            try DataManager.storeLevels(levelTable)
        } catch {
            print("Failed to save \(levelName) to database")
        }
    }
}
