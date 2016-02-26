//
//  Bubble.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 31/1/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import UIKit

/// A basic bubble which has a color attribute, for level designs
class GridBubble: AbstractBubble {
    private var power = BubblePower.none
    private var marked = false
    
    init(row: Int, col: Int) {
        super.init(row: row, col: col, color: BubbleColor.uninitalized)
    }
    
    func setPower(power: BubblePower) {
        self.power = power
    }
    
    func getPower() -> BubblePower {
        return power
    }
    /// sets the color of the bubble
 //   func setColor(newColor: BubbleColor) {
   //     color = newColor
    //}
    
    /// - returns the color of the bubble
 //   func getColor() -> BubbleColor {
  //      return color
    //}
    func mark() {
        marked = true
    }
    func unmark() {
        marked = false
    }
    func isMarked() -> Bool {
        return marked
    }
    
    /// encodes a GridBubble object
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeInteger(power.rawValue, forKey: "power")
    //    coder.encodeInteger(getRow(), forKey: "row")
      //  coder.encodeInteger(getCol(), forKey: "col")
        //coder.encodeInteger(self.color.rawValue, forKey: "color")
        //print(color)
    }
    
    /// reinstantiates an encoded GridBubble object
    required convenience init(coder decoder: NSCoder) {
        //super.init(coder: decoder)
        let row = decoder.decodeIntegerForKey("row")
        let col = decoder.decodeIntegerForKey("col")
        let color = decoder.decodeIntegerForKey("color")
        let power = decoder.decodeIntegerForKey("power")
        self.init(row: row, col: col)
        self.setColor(BubbleColor(rawValue: color)!)
        self.setPower(BubblePower(rawValue: power)!)
    }
}


enum BubblePower: Int {
    case none, indestructible, lightning, bomb, star
}