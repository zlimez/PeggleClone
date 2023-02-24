//
//  Math.swift
//  Peggle
//
//  Created by James Chiu on 24/2/23.
//

import Foundation

final class Math {
    static func sign(_ num: CGFloat) -> Int {
        num == 0 ? 0 : num > 0 ? 1 : -1;
    }
    
    static func clamp(num: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(maximum, max(minimum, num))
    }
}
