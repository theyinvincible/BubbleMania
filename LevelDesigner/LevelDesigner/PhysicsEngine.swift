//
//  PhysicsEngine.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 12/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation

class PhysicsEngine {
    private var topBoundary = 0.0
    private var bottomBoundary = 0.0
    private var leftBoundary = 0.0
    private var rightBoundary = 0.0
    private var timeStep = 0.0
    private var isReflectingLeftWall = false
    private var isReflectingRightWall = false
    private var isReflectingBottomWall = false
    private var isReflectingTopWall = false
        
    init(topBound: Double, bottomBound: Double, leftBound: Double, rightBound: Double) {
        if (topBound < bottomBound) && (rightBound > leftBound) {
            self.topBoundary = topBound
            self.bottomBoundary = bottomBound
            self.rightBoundary = rightBound
            self.leftBoundary = leftBound
        }
    }
    
    /// Sets the time step
    func setTimeStep(timeStep: Double) {
        self.timeStep = timeStep
    }
    
    /// - returns the next position and angle, given the source position of the object centre, angle and velocity
    func getNextPosition(srcX: Double, srcY: Double, width: Double, height: Double, angle: Double, velocity: Double) -> Vector {
        let length = velocity * timeStep
        let newXPos = length*cos(angle) + srcX
        let newYPos = srcY - length*sin(angle)
        var newAngle = angle
        if (isTouchingLeftWall(newXPos) && isReflectingLeftWall) || (isTouchingRightWall(newXPos, width: width) && isReflectingRightWall) {
            newAngle = M_PI - angle
        } else if (isTouchingTopWall(newYPos) && isReflectingTopWall) || (isTouchingBottomWall(newYPos, height: height) && isReflectingBottomWall) {
            newAngle = -newAngle
        }
        return Vector(xPos: newXPos, yPos: newYPos, angle: newAngle)
    }
    
    /// - returns whether the object is touching the top boundary set, yPos is the y coord of top right corner of object
    func isTouchingTopWall(yPos: Double) -> Bool {
        return yPos <= topBoundary
    }
    
    /// - returns whether the object is touching the bottom boundary set, yPos is the y coord of top right corner of object
    func isTouchingBottomWall(yPos: Double, height: Double) -> Bool {
        return (yPos + height) >= bottomBoundary
    }
    
    /// - returns whether the object is touching the right boundary set, xPos is the x coord of top right corner of object
    func isTouchingRightWall(xPos: Double, width: Double) -> Bool {
        return xPos + width >= rightBoundary
    }
    
    /// - returns whether the object is touching the left boundary set, xPos is the x coord of top right corner of object
    func isTouchingLeftWall(xPos: Double) -> Bool {
        return xPos <= leftBoundary
    }
    
    /// Sets whether object is to bounce off defined boundaries
    func setReflectionOfProjectile(top: Bool, bottom: Bool, right: Bool, left: Bool) {
        self.isReflectingTopWall = top
        self.isReflectingBottomWall = bottom
        self.isReflectingRightWall = right
        self.isReflectingLeftWall = left
    }
    
    /// Determines if two circles collide
    /// x and y refer to the coordinates of the centre of a circle
    /// - returns value indicating whether there is a collision
    func circlesIntersect(x1: Double, y1: Double, r1: Double, x2: Double, y2: Double, r2: Double) -> Bool {
        let dx = x1 - x2;
        let dy = y1 - y2;
        let distance = sqrt(dx * dx + dy * dy);
        if distance <= (r1 + r2) {
            return true
        } else {
            return false
        }
    }
}

struct Vector: Equatable {
    let xCoord: Double
    let yCoord: Double
    let angle: Double
    
    init (xPos: Double, yPos: Double, angle: Double) {
        self.xCoord = xPos
        self.yCoord = yPos
        self.angle = angle
    }
}
func == (lhs: Vector, rhs: Vector) -> Bool {
    return lhs.xCoord == rhs.xCoord && lhs.yCoord == rhs.yCoord && lhs.angle == rhs.angle
}