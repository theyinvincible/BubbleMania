//
//  PhysicsEngineTest.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 14/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import XCTest
import Foundation
@testable import LevelDesigner

class PhysicsEngineTests: XCTestCase {
    
    func testGetNextPosition() {
        // no reflection
        let engine = PhysicsEngine(topBound: 0, bottomBound: 200, leftBound: 0, rightBound: 200)
        engine.setTimeStep(1)
        
        var actual = engine.getNextPosition(0, srcY: 0, width: 20, height: 10, angle: 0, velocity: 10)
        XCTAssertEqual(actual, Vector(xPos: 10, yPos: 0, angle: 0), "next position is wrong for travelling to the right")
    }
    
    func testCirclesIntersect() {
        let engine = PhysicsEngine(topBound: 0, bottomBound: 200, leftBound: 0, rightBound: 200)
        var actual = engine.circlesIntersect(5, y1: 5, r1: 5, x2: 15, y2: 5, r2: 5)
        XCTAssert(actual, "circlesIntersect is wrong for two circles side by side")
        
        actual = engine.circlesIntersect(5, y1: 5, r1: 5, x2: 5, y2: 15, r2: 5)
        XCTAssert(actual, "circlesIntersect is wrong for two circles stacked")
        
        actual = engine.circlesIntersect(5, y1: 5, r1: 5, x2: 15.1, y2: 5, r2: 5)
        XCTAssert(!actual, "circlesIntersect is wrong for two circles side by side not touching each other")
        
        actual = engine.circlesIntersect(5, y1: 5, r1: 5, x2: 5-10*cos(M_PI/2), y2: 5-10*sin(M_PI/2), r2: 5)
        XCTAssert(actual, "circlesIntersect is wrong for two circles touching at an angle")
        
        actual = engine.circlesIntersect(5, y1: 5, r1: 5, x2: 8, y2: 5, r2: 5)
        XCTAssert(actual, "circlesIntersect is wrong for two overlapping circles")
    }
    
    func testIsTouchingBoundaries() {
        let engine = PhysicsEngine(topBound: 50, bottomBound: 200, leftBound: 50, rightBound: 100)
        var actual = engine.isTouchingBottomWall(199, height: 1)
        XCTAssert(actual, "isTouchingBottomWall is incorrect")
        actual = engine.isTouchingBottomWall(199, height: 2)
        XCTAssert(actual, "isTouchingBottomWall is incorrect")
        actual = engine.isTouchingBottomWall(190, height: 9)
        XCTAssert(!actual, "isTouchingBottomWall is incorrect")
        
        actual = engine.isTouchingTopWall(50)
        XCTAssert(actual, "isTouchingTopWall is incorrect")
        actual = engine.isTouchingTopWall(49)
        XCTAssert(actual, "isTouchingTopWall is incorrect")
        actual = engine.isTouchingTopWall(51)
        XCTAssert(!actual, "isTouchingTopWall is incorrect")

        actual = engine.isTouchingRightWall(99, width: 1)
        XCTAssert(actual, "isTouchingRightWall is incorrect")
        actual = engine.isTouchingRightWall(99, width: 2)
        XCTAssert(actual, "isTouchingRightWall is incorrect")
        actual = engine.isTouchingRightWall(98, width: 1)
        XCTAssert(!actual, "isTouchingRightWall is incorrect")

        actual = engine.isTouchingLeftWall(50)
        XCTAssert(actual, "isTouchingLeftWall is incorrect")
        actual = engine.isTouchingLeftWall(49)
        XCTAssert(actual, "isTouchingLeftWall is incorrect")
        actual = engine.isTouchingLeftWall(51)
        XCTAssert(!actual, "isTouchingLeftWall is incorrect")
    }
}

