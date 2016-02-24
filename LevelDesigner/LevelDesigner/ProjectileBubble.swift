//
//  ProjectileBubble.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 13/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation

class ProjectileBubble: BasicBubble {
    private var xPos, yPos: Double
    private let hasPower: Bool
    
    init(xPos: Double, yPos: Double, hasPower: Bool) {
        self.hasPower = hasPower
        self.xPos = xPos
        self.yPos = yPos
        super.init(row: -1, col: -1)
    }
    
    /// Updates position of top left corner
    func updatePosition(xPos: Double, yPos: Double) {
        self.xPos = xPos
        self.yPos = yPos
    }
    
    /// - returns x-coordinate of top left corner
    func getXPos() -> Double {
        return xPos
    }
    
    /// - returns y-coordinate of top left corner
    func getYPos() -> Double {
        return yPos
    }
    
    /// - returns whether the projectile bubble is a power bubble
    func isPowerBubble() -> Bool {
        return hasPower
    }

    required convenience init(coder decoder: NSCoder) {
        self.init(xPos: 0, yPos: 0, hasPower: false)
    }
}