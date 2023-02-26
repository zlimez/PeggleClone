//
//  ScoreSystem.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

protocol ScoreSystem {
    var score: Int { get }
    func updateBaseScore(_ pegRemoved: PegRB)
    // Called to apply compound or side effects
    func updateScore()
    func reset()
}