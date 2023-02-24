//
//  RenderAdaptor.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

protocol GameSystem {
    mutating func adaptScene(_ worldObjects: any Collection<WorldObject>)
}
