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
    private var power: BubblePower
    
    init(frame: CGRect, row: Int, col: Int) {
        self.row = row
        self.col = col
        color = BubbleColor.uninitalized
        power = BubblePower.none
        super.init(frame: frame)
        layer.cornerRadius = self.frame.size.width/2
        clipsToBounds = true
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 2.0
        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
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
            backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
            color = newColor
            power = BubblePower.none
        case BubbleColor.red:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.redBubbleImage!, view: self))
            color = newColor
            power = BubblePower.none
        case BubbleColor.orange:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.orangeBubbleImage!, view: self))
            color = newColor
            power = BubblePower.none
        case BubbleColor.green:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.greenBubbleImage!, view: self))
            color = newColor
            power = BubblePower.none
        case BubbleColor.blue:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.blueBubbleImage!, view: self))
            color = newColor
            power = BubblePower.none
        default:
            break           // how to do setting of power
        }
    }
    
    func setPower(newPower: BubblePower) {
        switch newPower {
        case BubblePower.lightning:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.lightningBubbleImage!, view: self))
            color = BubbleColor.power
            power = BubblePower.lightning
        case BubblePower.indestructible:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.indestructibleBubbleImage!, view: self))
            color = BubbleColor.power
            power = BubblePower.indestructible
        case BubblePower.bomb:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.bombBubbleImage!, view: self))
            color = BubbleColor.power
            power = BubblePower.bomb
        case BubblePower.star:
            backgroundColor = UIColor(patternImage: scaleImage(Constants.starBubbleImage!, view: self))
            color = BubbleColor.power
            power = BubblePower.star
        default:
            break
        }
    }
    
    func getPower() -> BubblePower {
        return power
    }
    
    /// Next color is set in a cycle sequence of red -> orange -> green -> blue -> red.
    func setNextCycleColor() {
        var newColor = BubbleColor.uninitalized
        switch color {
        case BubbleColor.red:
            newColor = BubbleColor.orange
            setColor(newColor)
        case BubbleColor.orange:
            newColor = BubbleColor.green
            setColor(newColor)
        case BubbleColor.green:
            newColor = BubbleColor.blue
            setColor(newColor)
        case BubbleColor.blue:
            newColor = BubbleColor.red
            setColor(newColor)
        default:
            break
        }
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