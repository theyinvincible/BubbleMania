//
//  LevelDesign.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 24/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation

class LevelDesign: NSObject, NSCoding {
    private var bubbleData: [Int: [Int: BasicBubble]]
    
    override init() {
        bubbleData = [Int: [Int: BasicBubble]]()
    }
    
    init(gridData: [Int: [Int: BasicBubble]]) {
        bubbleData = gridData
    }
    
    func addBubble(bubble: BasicBubble) {
        let row = bubble.getRow()
        let col = bubble.getCol()
        if !bubbleData.keys.contains(row) {
            bubbleData[row] = [Int: BasicBubble]()
        }
        bubbleData[row]![col] = bubble
    }
    
    func getBubble(row: Int, col: Int) -> BasicBubble? {
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
        if bubbleData.keys.contains(row) {
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
    
    /// enumerate all bubble views stored in the grid
    func getBubbleArray() -> [BasicBubble] {
        var bubbleArray = [BasicBubble]()
        for key in bubbleData.keys {
            bubbleArray.appendContentsOf(bubbleData[key]!.values)
        }
        return bubbleArray
    }
    
    /// encodes a BasicBubble object
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(bubbleData, forKey: "grid")
    }
    
    /// reinstantiates an encoded BasicBubble object
    required convenience init(coder decoder: NSCoder) {
        let gridData = decoder.decodeObjectForKey("grid") as! [Int: [Int: BasicBubble]]
        self.init(gridData: gridData)
    }
}