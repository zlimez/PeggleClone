//
//  Fadable.swift
//  Peggle
//
//  Created by James Chiu on 1/3/23.
//

import Foundation

protocol Fadable {
    associatedtype Element: PegRB
    var fadableBody: Element { get }
    var fadeTime: Double { get }
    var afterFade: () -> Void { get set }
}

extension Fadable {
    func makeFade() {
        guard let activeGameBoard = GameWorld.activeGameBoard else {
            fatalError("No active board")
        }
        activeGameBoard.addCoroutine(Coroutine(routine: fade, onCompleted: activeGameBoard.removeCoroutine))
    }

    func fade(deltaTime: Double) -> Bool {
        fadableBody.spriteContainer.opacity -= deltaTime / fadeTime
        if fadableBody.spriteContainer.opacity <= 0 {
            afterFade()
            return true
        }
        return false
    }
}
