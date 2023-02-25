//
//  HostilePeg.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

enum ThreatLevel {
    case low, high
}

class HostilePeg: NormalPeg {
    var threatLevel: ThreatLevel
    
    init(peg: Peg, threatLevel: ThreatLevel) {
        self.threatLevel = threatLevel
        super.init(peg)
    }
}
