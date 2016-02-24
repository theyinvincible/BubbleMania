//
//  BubbleView.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 24/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation
import UIKit

class BubbleView: UIView {
    private var color: BubbleColor
    private var row: Int
    private var col: Int
    
    init(frame: CGRect, row: Int, col: Int) {
        self.color = BubbleColor.uninitalized
        self.row = row
        self.col = col
        super.init(frame: frame)
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0
        self.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
    }

    func getRow() -> Int {
        return row
    }
    
    func getCol() -> Int {
        return col
    }
    
    func getColor() -> BubbleColor {
        return color
    }
    
    // Sets the view of the bubble to the color given in the parameter
    func setColor(newColor: BubbleColor) {
        switch newColor {
        case BubbleColor.uninitalized:
            self.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        case BubbleColor.red:
            self.backgroundColor = UIColor(patternImage: scaleImage(Constants.redBubbleImage!, view: self))
        case BubbleColor.orange:
            self.backgroundColor = UIColor(patternImage: scaleImage(Constants.orangeBubbleImage!, view: self))
        case BubbleColor.green:
            self.backgroundColor = UIColor(patternImage: scaleImage(Constants.greenBubbleImage!, view: self))
        case BubbleColor.blue:
            self.backgroundColor = UIColor(patternImage: scaleImage(Constants.blueBubbleImage!, view: self))
        }
        color = newColor
    }
    
    /// Next color is set in a cycle sequence of red -> orange -> green -> blue -> red.
    /// - returns the new color being set to the bubble
    func setNextCycleColor() {
        var newColor = BubbleColor.uninitalized
        switch color {
        case BubbleColor.red:
            newColor = BubbleColor.orange
        case BubbleColor.orange:
            newColor = BubbleColor.green
        case BubbleColor.green:
            newColor = BubbleColor.blue
        case BubbleColor.blue:
            newColor = BubbleColor.red
        default:
            break
        }
        setColor(newColor)
    }
    
    /// scales an image to fit the given view
    private func scaleImage(image: UIImage, view: UIView) -> UIImage {
        let size = view.frame.size
        let hasAlpha = false        //change to true
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}