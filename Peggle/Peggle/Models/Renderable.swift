//
//  Renderable.swift
//  Peggle
//
//  Created by James Chiu on 24/2/23.
//

import Foundation

protocol Renderable {
    var id: Int { get }
    var spriteContainer: SpriteContainer { get set }
    var x: CGFloat { get }
    var y: CGFloat { get }
    var spriteOpacity: CGFloat { get }
    var spriteWidth: CGFloat { get }
    var spriteHeight: CGFloat { get }
    var rotation: CGFloat { get }
}
