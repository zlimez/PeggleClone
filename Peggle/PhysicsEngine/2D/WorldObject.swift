//
//  WorldObject.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

class WorldObject: Hashable, Identifiable {
    private static var objectCounter = 0
    let id: Int
    var transform: Transform
    
    static func resetCounter() {
        objectCounter = 0
    }

    init(_ transform: Transform) {
        self.id = WorldObject.objectCounter
        self.transform = transform
        WorldObject.objectCounter += 1
    }
    
    static func == (lhs: WorldObject, rhs: WorldObject) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
