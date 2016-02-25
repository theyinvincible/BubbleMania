//
//  AbstractBubble.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 7/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import UIKit

/// Base class for all bubble objects
/// Contains position of bubble
class AbstractBubble: NSObject, NSCoding {
    private let row: Int
    private let col: Int
    private var color: BubbleColor
    
    init(row: Int, col: Int, color: BubbleColor) {
        self.row = row
        self.col = col
        self.color = color
    }
    
    func setColor(newColor: BubbleColor) {
        color = newColor
    }
    
    /// - returns row that bubble resides on
    func getRow() -> Int {
        return row
    }
    
    /// - returns col that bubble resides on
    func getCol() -> Int {
        return col
    }
    
    func getColor() -> BubbleColor {
        return color
    }
    
    /// encodes an AbstractBubble object
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(getRow(), forKey: "row")
        coder.encodeInteger(getCol(), forKey: "col")
        coder.encodeInteger(self.color.rawValue, forKey: "color")
    }
    
    /// reinstantiates an encoded AbstractBubble object
    required convenience init(coder decoder: NSCoder) {
        let row = decoder.decodeIntegerForKey("row")
        let col = decoder.decodeIntegerForKey("col")
        let color = decoder.decodeIntegerForKey("color")
        self.init(row: row, col: col, color: BubbleColor(rawValue: color)!)
    }
}


enum BubbleColor: Int {
    case uninitalized, red, orange, green, blue, power
}