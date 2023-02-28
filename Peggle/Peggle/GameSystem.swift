//
//  RenderAdaptor.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

protocol GameSystem {
    var adaptScene: (any Collection<WorldObject>) -> Void { get }
}
