//
//  Bubble.swift
//  BubbleMania
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
    
    /// sets the power of the bubble
    func setPower(power: BubblePower) {
        self.power = power
    }
    
    /// - returns the power of the bubble
    func getPower() -> BubblePower {
        return power
    }
    
    /// marks a bubble
    func mark() {
        marked = true
    }
    
    /// unmarks a bubble
    func unmark() {
        marked = false
    }
    
    /// - returns whether the bubble is marked
    func isMarked() -> Bool {
        return marked
    }
    
    /// encodes a GridBubble object
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeInteger(power.rawValue, forKey: Constants.coderPowerKey)
    }
    
    /// reinstantiates an encoded GridBubble object
    required convenience init(coder decoder: NSCoder) {
        //super.init(coder: decoder)
        let row = decoder.decodeIntegerForKey(Constants.coderRowKey)
        let col = decoder.decodeIntegerForKey(Constants.coderColKey)
        let color = decoder.decodeIntegerForKey(Constants.coderColorKey)
        let power = decoder.decodeIntegerForKey(Constants.coderPowerKey)
        self.init(row: row, col: col)
        self.setColor(BubbleColor(rawValue: color)!)
        self.setPower(BubblePower(rawValue: power)!)
    }
}

enum BubblePower: Int {
    case none, indestructible, lightning, bomb, star
}