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
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    /// - returns row that bubble resides on
    func getRow() -> Int {
        return row
    }
    
    /// - returns col that bubble resides on
    func getCol() -> Int {
        return col
    }
    
    /// encodes an AbstractBubble object
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(getRow(), forKey: "row")
        coder.encodeInteger(getCol(), forKey: "col")
    }
    
    /// reinstantiates an encoded AbstractBubble object
    required convenience init(coder decoder: NSCoder) {
        let row = decoder.decodeIntegerForKey("row")
        let col = decoder.decodeIntegerForKey("col")
        self.init(row: row, col: col)
    }
}