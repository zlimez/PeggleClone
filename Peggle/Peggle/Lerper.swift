//
//  Lerper.swift
//  Peggle
//
//  Created by James Chiu on 24/2/23.
//

import Foundation

final class Lerper {
    static func linearLerpFloat(from: CGFloat, to: CGFloat, t: CGFloat) -> CGFloat {
        let clampedT = Math.clamp(num: t, minimum: 0, maximum: 1)
        return from + (from - to) * clampedT
    }
    
    static func cubicLerpFloat(from: CGFloat, to: CGFloat, t: CGFloat) -> CGFloat {
        let clampedT = Math.clamp(num: t, minimum: 0, maximum: 1)
        return linearLerpFloat(from: from, to: to, t: 1 + pow(clampedT - 1, 3))
    }
}
