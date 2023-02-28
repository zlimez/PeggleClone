//
//  PegCategorizer.swift
//  Peggle
//
//  Created by James Chiu on 28/2/23.
//

import Foundation

protocol PegCategorizer {
    func isCivilian() -> Bool
    func isHostile() -> Bool
    func isBomb() -> Bool
    func isSpy() -> Bool
    func isBond() -> Bool
}
