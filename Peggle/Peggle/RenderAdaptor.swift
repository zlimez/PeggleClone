//
//  RenderAdaptor.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

protocol RenderAdaptor {
    mutating func adaptScene(_ bodies: [RigidBody])
}
