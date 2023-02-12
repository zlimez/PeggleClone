//
//  Line.swift
//  Peggle
//
//  Created by James Chiu on 12/2/23.
//

import Foundation

final class LineUtils {
    static func checkPointInLineSegment(startPoint: Vector2, endPoint: Vector2, checkedPoint: Vector2) -> Bool {
        let xRatio = (checkedPoint.x - startPoint.x) / (endPoint.x - startPoint.x)
        let yRatio = (checkedPoint.y - startPoint.y) / (endPoint.y - startPoint.y)
        
        return xRatio == yRatio && xRatio >= 0 && xRatio <= 1
    }
}
