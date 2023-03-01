//
//  Chainable.swift
//  Peggle
//
//  Created by James Chiu on 1/3/23.
//

import Foundation

protocol Chainable {
    var parent: Chainable? { get set }
    var localTransform: Transform { get set }
    func globalToLocal()
}
