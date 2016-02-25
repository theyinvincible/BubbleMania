//
//  Bubble.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 31/1/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import UIKit

/// A basic bubble which has a color attribute, for level designs
class BasicBubble: AbstractBubble {
    private var color = BubbleColor.uninitalized
    
    override init(row: Int, col: Int) {
        super.init(row: row, col: col)
    }
    
    /// sets the color of the bubble
    func setColor(newColor: BubbleColor) {
        color = newColor
    }
    
    /// - returns the color of the bubble
    func getColor() -> BubbleColor {
        return color
    }
    
    /// encodes a BasicBubble object
    override func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(getRow(), forKey: "row")
        coder.encodeInteger(getCol(), forKey: "col")
        coder.encodeInteger(self.color.rawValue, forKey: "color")
    }
    
    /// reinstantiates an encoded BasicBubble object
    required convenience init(coder decoder: NSCoder) {
        let row = decoder.decodeIntegerForKey("row")
        let col = decoder.decodeIntegerForKey("col")
        let color = decoder.decodeIntegerForKey("color")
        self.init(row: row, col: col)
        self.setColor(BubbleColor(rawValue: color)!)
    }
}

enum BubbleColor: Int {
    case uninitalized, red, orange, green, blue
}

enum BubblePower: Int {
    case none, indestructible, lightning, bomb, star
}