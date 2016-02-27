//
//  LevelDesign.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 24/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation

class LevelDesign: NSObject, NSCoding {
    private var bubbleData: [Int: [Int: GridBubble]]
    
    override init() {
        bubbleData = [Int: [Int: GridBubble]]()
    }
    
    init(gridData: [Int: [Int: GridBubble]]) {
        bubbleData = gridData
    }
    
    func addBubble(bubble: GridBubble) {
        let row = bubble.getRow()
        let col = bubble.getCol()
        if !bubbleData.keys.contains(row) {
            bubbleData[row] = [Int: GridBubble]()
        }
        bubbleData[row]![col] = bubble
    }
    
    func getBubble(row: Int, col: Int) -> GridBubble? {
        if containsBubble(row, col: col) {
            return bubbleData[row]![col]!
        }
        return nil
    }
    
    func removeBubble(row: Int, col: Int) {
        if containsBubble(row, col: col) {
            bubbleData[row]!.removeValueForKey(col)
            if bubbleData[row]!.keys.isEmpty {
                bubbleData.removeValueForKey(row)
            }
        }
    }
    
    func rowIsEmpty(row: Int) -> Bool {
        if bubbleData.keys.contains(row) {  //this wrong 
            return true
        }
        return false
    }
    
    func removeAllEmptyBubbles() {
        let bubbles = getBubbleArray()
        for bubble in bubbles {
            if bubble.getColor() == BubbleColor.uninitalized {
                removeBubble(bubble.getRow(), col: bubble.getCol())
            }
        }
    }
    
    /// returns bool value of whether there is a bubble stored in the design
    func containsBubble(row: Int, col: Int) -> Bool {
        if bubbleData.keys.contains(row) {
            if bubbleData[row]!.keys.contains(col) {
                return true
            }
        }
        return false
    }
    
    /// returns an array of bubbles which reside in the given row
    func getBubblesInRow(row: Int) -> [GridBubble] {
        var rowBubbles = [GridBubble]()
        if bubbleData.keys.contains(row) {
            rowBubbles.appendContentsOf(bubbleData[row]!.values)
        }
        return rowBubbles
    }
    
    /// enumerate all bubble views stored in the grid
    func getBubbleArray() -> [GridBubble] {
        var bubbleArray = [GridBubble]()
        for key in bubbleData.keys {
            bubbleArray.appendContentsOf(bubbleData[key]!.values)
        }
        return bubbleArray
    }
    
    /// returns array of bubbles with the same color
    func getBubblesOfColor(color: BubbleColor) -> [GridBubble] {
        var coloredBubbles = [GridBubble]()
        for bubble in getBubbleArray() {
            if bubble.getColor() == color {
                coloredBubbles.append(bubble)
            }
        }
        return coloredBubbles
    }
    
    /// encodes a GridBubble object
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(bubbleData, forKey: "grid")
    }
    
    /// reinstantiates an encoded GridBubble object
    required convenience init(coder decoder: NSCoder) {
        let gridData = decoder.decodeObjectForKey("grid") as! [Int: [Int: GridBubble]]
        self.init(gridData: gridData)
    }
}