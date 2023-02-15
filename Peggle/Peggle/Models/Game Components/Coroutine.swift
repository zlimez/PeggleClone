//
//  Coroutine.swift
//  Peggle
//
//  Created by James Chiu on 15/2/23.
//

import Foundation

class Coroutine: Hashable {
    static var counter = 0
    let id: Int
    let routine: (Double) -> Bool
    let onCompleted: (Coroutine) -> Void

    init(routine: @escaping (Double) -> Bool, onCompleted: @escaping (Coroutine) -> Void) {
        self.routine = routine
        self.onCompleted = onCompleted
        self.id = Coroutine.counter
        Coroutine.counter += 1
    }

    func execute(_ deltaTime: Double) {
        if routine(deltaTime) {
            onCompleted(self)
        }
    }

    static func == (lhs: Coroutine, rhs: Coroutine) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
