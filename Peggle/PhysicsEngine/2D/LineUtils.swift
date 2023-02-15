//
//  Line.swift
//  Peggle
//
//  Created by James Chiu on 12/2/23.
//

import Foundation

final class LineUtils {
    static func checkPointInLineSegment(lineStart: Vector2, lineEnd: Vector2, checkedPoint: Vector2) -> Bool {
        let lineLength = Vector2.distance(a: lineStart, b: lineEnd)
        let distanceFromStart = Vector2.distance(a: lineStart, b: checkedPoint)
        let distanceFromEnd = Vector2.distance(a: lineEnd, b: checkedPoint)

        return distanceFromStart + distanceFromEnd == lineLength
    }
}
