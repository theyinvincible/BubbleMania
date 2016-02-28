//
//  BubbleGridView.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 23/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation
import UIKit

class BubbleGridView: UIView {
    private var bubbleViewStorage = [Int: [Int: BubbleView]]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var offsetX: CGFloat
        var offsetY = frame.minY
        var numCols: Int
        let numRows = Constants.gridNumRows
        let cellWidth = frame.size.width/CGFloat(Constants.gridNumColsForEvenRow)
        
        // set up a full grid view of empty bubble cells
        for row in 0..<numRows {
            if row%2 == 0 {
                numCols = Constants.gridNumColsForEvenRow
                offsetX = frame.minX
            } else {
                numCols = Constants.gridNumColsForOddRow
                offsetX = cellWidth/2
            }
            for col in 0..<numCols {
                let bubbleCell = BubbleView(frame: CGRectMake(offsetX, offsetY, cellWidth, cellWidth), row: row, col: col)
                self.addSubview(bubbleCell)
                addBubbleViewToStorage(bubbleCell)
                offsetX += cellWidth
            }
            offsetY += (Constants.adjustRowSeparation) * cellWidth
        }
    }
    
    
    /// - returns the bubble view for a bubble stored in a specific row and column
    func getBubbleView(row: Int, col: Int) -> BubbleView? {
        if containsBubbleViewAtPosition(row, col: col) {
            return bubbleViewStorage[row]![col]
        }
        return nil
    }
    
    /// adds a bubble view to the existing grid view
    /// - returns the newly added bubble view
    func addBubbleView(row: Int, col: Int) -> BubbleView {
        var offsetX: CGFloat
        let cellWidth = frame.size.width/CGFloat(Constants.gridNumColsForEvenRow)
        if row%2 == 0 {
            offsetX = frame.minX
        } else {
            offsetX = cellWidth/2
        }
        offsetX += cellWidth*CGFloat(col)
        let offsetY = frame.minY + Constants.adjustRowSeparation * cellWidth * CGFloat(row)
        let bubbleCell = BubbleView(frame: CGRectMake(offsetX, offsetY, cellWidth, cellWidth), row: row, col: col)
        self.addSubview(bubbleCell)
        addBubbleViewToStorage(bubbleCell)
        return bubbleCell
    }
    
    /// Helper function to add bubbleViews into the grid's data
    private func addBubbleViewToStorage(bubbleView: BubbleView) {
        let row = bubbleView.getRow()
        let col = bubbleView.getCol()
        if !bubbleViewStorage.keys.contains(row) {
            bubbleViewStorage[row] = [Int: BubbleView]()
        }
        bubbleViewStorage[row]![col] = bubbleView
    }
    
    /// removes an existing bubble view from the grid
    func removeBubbleViewAtPosition(row: Int, col: Int) {
        if containsBubbleViewAtPosition(row, col: col) {
            let removedBubble = bubbleViewStorage[row]![col]
            removedBubble!.removeFromSuperview()
            bubbleViewStorage[row]!.removeValueForKey(col)
        }
    }
    
    /// the grid view matches to display the BubbleGrid data given
    /// *for loading level designs
    func setGridDesign(gridDesign: BubbleGrid) {
        for bubble in gridDesign.getBubbleArray() {
            let row = bubble.getRow()
            let col = bubble.getCol()
            let color = bubble.getColor()
            let power = bubble.getPower()
            if let bubbleView = getBubbleView(row, col: col) {
                bubbleView.setColor(color)
                bubbleView.setPower(power)
            }
        }
    }
    
    /// instantiates a gridview based on a BubbleGrid
    /// *for game play
    init(frame: CGRect, gridDesign: BubbleGrid) {
        super.init(frame: frame)
        for bubble in gridDesign.getBubbleArray() {
            let row = bubble.getRow()
            let col = bubble.getCol()
            let color = bubble.getColor()
            let power = bubble.getPower()
            if let bubbleView = getBubbleView(row, col: col) {
                bubbleView.setColor(color)
                bubbleView.setPower(power)
            } else {
                let newBubbleView = addBubbleView(row, col: col)
                newBubbleView.setColor(color)
                newBubbleView.setPower(power)
            }
        }
    }
    
    /// - returns whether there exists a bubble view at (row, col)
    func containsBubbleViewAtPosition(row: Int, col: Int) -> Bool {
        if bubbleViewStorage.keys.contains(row) {
            if bubbleViewStorage[row]!.keys.contains(col) {
                return true
            }
        }
        return false
    }
    
    /// enumerate all bubble views stored in the grid
    func getBubbleViewArray() -> [BubbleView] {
        var bubbleViewArray = [BubbleView]()
        for key in bubbleViewStorage.keys {
            bubbleViewArray.appendContentsOf(bubbleViewStorage[key]!.values)
        }
        return bubbleViewArray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}