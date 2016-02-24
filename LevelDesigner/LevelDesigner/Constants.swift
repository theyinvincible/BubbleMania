//
//  Constants.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 23/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    // image files
    static let redBubbleImageFile = "bubble-red.png"
    static let blueBubbleImageFile = "bubble-blue.png"
    static let orangeBubbleImageFile = "bubble-orange.png"
    static let greenBubbleImageFile = "bubble-green.png"
    static let eraserImageFile = "eraser-1.png"
    
    static let redBubbleImage = UIImage(named: redBubbleImageFile)
    static let orangeBubbleImage = UIImage(named: orangeBubbleImageFile)
    static let greenBubbleImage = UIImage(named: greenBubbleImageFile)
    static let blueBubbleImage = UIImage(named: blueBubbleImageFile)
    static let eraserImage = UIImage(named: eraserImageFile)
    
    static let gridNumRows = 9
    static let gridNumColsForEvenRow = 12
    static let gridNumColsForOddRow = 11
    static let adjustRowSeparation = CGFloat(6.7/8)
}

