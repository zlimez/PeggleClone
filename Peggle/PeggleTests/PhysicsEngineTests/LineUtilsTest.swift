//
//  LineUtilsTest.swift
//  PeggleTests
//
//  Created by James Chiu on 15/2/23.
//

import XCTest
@testable import Peggle

class LineUtilsTest: XCTestCase {
    func testPointInMiddleOfLineSegment() {
        // Test a point in the middle of a line segment
        let lineStart = Vector2(x: 0, y: 0)
        let lineEnd = Vector2(x: 10, y: 10)
        let checkedPoint = Vector2(x: 5, y: 5)

        XCTAssertTrue(LineUtils.checkPointInLineSegment(
            lineStart: lineStart,
            lineEnd: lineEnd,
            checkedPoint: checkedPoint
        ))
    }

    func testPointOnStartOfLineSegment() {
        // Test a point on the start of a line segment
        let lineStart = Vector2(x: 0, y: 0)
        let lineEnd = Vector2(x: 10, y: 10)
        let checkedPoint = Vector2(x: 0, y: 0)

        XCTAssertTrue(LineUtils.checkPointInLineSegment(
            lineStart: lineStart,
            lineEnd: lineEnd,
            checkedPoint: checkedPoint
        ))
    }

    func testPointOnEndOfLineSegment() {
        // Test a point on the end of a line segment
        let lineStart = Vector2(x: 0, y: 0)
        let lineEnd = Vector2(x: 10, y: 10)
        let checkedPoint = Vector2(x: 10, y: 10)

        XCTAssertTrue(LineUtils.checkPointInLineSegment(
            lineStart: lineStart,
            lineEnd: lineEnd,
            checkedPoint: checkedPoint
        ))
    }

    func testPointOutsideLineSegment() {
        // Test a point outside of a line segment
        let lineStart = Vector2(x: 0, y: 0)
        let lineEnd = Vector2(x: 10, y: 10)
        let checkedPoint = Vector2(x: 11, y: 11)

        XCTAssertFalse(LineUtils.checkPointInLineSegment(
            lineStart: lineStart,
            lineEnd: lineEnd,
            checkedPoint: checkedPoint
        ))
    }

    func testPointOnLineExtension() {
        // Test a point on the extension of a line
        let lineStart = Vector2(x: 0, y: 0)
        let lineEnd = Vector2(x: 10, y: 10)
        let checkedPoint = Vector2(x: -1, y: -1)

        XCTAssertFalse(LineUtils.checkPointInLineSegment(
            lineStart: lineStart,
            lineEnd: lineEnd,
            checkedPoint: checkedPoint
        ))
    }
}
