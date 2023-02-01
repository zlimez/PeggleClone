//
//  PeggleTests.swift
//  PeggleTests
//
//  Created by James Chiu on 25/1/23.
//

import XCTest
@testable import Peggle

final class PegTests: XCTestCase {
    func testInitWithAllValues() {
        let peg = Peg(pegColor: "red", radius: 10, bounciness: 0.5, x: 20, y: 30)
        XCTAssertEqual(peg.id, Peg.getCounter() - 1)
        XCTAssertEqual(peg.pegColor, "red")
        XCTAssertEqual(peg.radius, 10)
        XCTAssertEqual(peg.bounciness, 0.5)
        XCTAssertEqual(peg.x, 20)
        XCTAssertEqual(peg.y, 30)
    }

    func testInitWithMissingBouncinessValue() {
        let peg = Peg(pegColor: "red", radius: 10, x: 20, y: 30)
        XCTAssertEqual(peg.bounciness, 1)
    }

    func testInitWithInvalidRadiusValue() {
        let peg = Peg(pegColor: "red", radius: -10, x: 20, y: 30)
        XCTAssertEqual(peg.radius, 1)
    }

    func testUpdatePositionTo() {
        let peg = Peg(pegColor: "red", radius: 10, x: 20, y: 30)
        peg.updatePositionTo(CGPoint(x: 40, y: 50))
        XCTAssertEqual(peg.x, 40)
        XCTAssertEqual(peg.y, 50)
    }

    func testGetCopy() {
        let peg = Peg(pegColor: "red", radius: 10, x: 20, y: 30)
        let pegCopy = peg.getCopy()
        XCTAssertNotEqual(peg, pegCopy)
        XCTAssertEqual(peg.pegColor, pegCopy.pegColor)
        XCTAssertEqual(peg.radius, pegCopy.radius)
        XCTAssertEqual(peg.bounciness, pegCopy.bounciness)
        XCTAssertEqual(peg.x, pegCopy.x)
        XCTAssertEqual(peg.y, pegCopy.y)
    }

    func testEquatable() {
        let peg1 = Peg(pegColor: "red", radius: 10, x: 20, y: 30)
        let peg2 = Peg(pegColor: "blue", radius: 5, x: 15, y: 25)
        XCTAssertNotEqual(peg1, peg2)
        XCTAssertEqual(peg1, peg1)
    }

    func testHashable() {
        let peg1 = Peg(pegColor: "red", radius: 10, x: 20, y: 30)
        let peg2 = Peg(pegColor: "blue", radius: 5, x: 15, y: 25)

        var set = Set<Peg>()
        set.insert(peg1)
        set.insert(peg2)
        XCTAssertEqual(set.count, 2)

        let peg3 = peg1
        set.insert(peg3)
        XCTAssertEqual(set.count, 2)
    }
}
