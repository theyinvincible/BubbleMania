//
//  ProjectileBubble.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 13/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation

class ProjectileBubble: AbstractBubble {
    private var xPos, yPos: Double
    private var color = BubbleColor.uninitalized
    
    init(xPos: Double, yPos: Double) {
        self.xPos = xPos
        self.yPos = yPos
        super.init(row: -1, col: -1, color: color)
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

    required convenience init(coder decoder: NSCoder) {
        self.init(xPos: 0, yPos: 0)
    }
}