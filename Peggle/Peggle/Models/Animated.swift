//
//  Animated.swift
//  Peggle
//
//  Created by James Chiu on 24/2/23.
//

import Foundation

protocol Animated: Renderable {
    var idleSprite: String { get }
    var spriteSheet: [String] { get }
    var animateSequences: [String: [Int]] { get }
    var frameRate: Float { get }
}
