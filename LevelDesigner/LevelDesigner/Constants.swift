//
//  Constants.swift
//  BubbleMania
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
    static let lightningBubbleImageFile = "bubble-lightning.png"
    static let bombBubbleImageFile = "bubble-bomb.png"
    static let starBubbleImageFile = "bubble-star.png"
    static let indestructibleBubbleImageFile = "bubble-indestructible.png"
    static let eraserImageFile = "eraser-1.png"
    static let backgroundImageFile = "background.png"

    static let redBubbleImage = UIImage(named: redBubbleImageFile)
    static let orangeBubbleImage = UIImage(named: orangeBubbleImageFile)
    static let greenBubbleImage = UIImage(named: greenBubbleImageFile)
    static let blueBubbleImage = UIImage(named: blueBubbleImageFile)
    static let lightningBubbleImage = UIImage(named: lightningBubbleImageFile)
    static let bombBubbleImage = UIImage(named: bombBubbleImageFile)
    static let starBubbleImage = UIImage(named: starBubbleImageFile)
    static let indestructibleBubbleImage = UIImage(named: indestructibleBubbleImageFile)
    static let eraserImage = UIImage(named: eraserImageFile)
    static let backgroundImage = UIImage(named: backgroundImageFile)
    
    static let uninitializedColorAlpha = CGFloat(0.3)
    static let unselectedAlpha =  CGFloat(0.6)
    static let selectedAlpha = CGFloat(1.0)
    static let firstPhaseAlpha = CGFloat(0.7)
    static let secondPhaseAlpha = CGFloat(0.5)
    static let thirdPhaseAlpha = CGFloat(0.3)
    
    static let numPreviewBubbles = 3
    static let animationCount = 15
    
    static let emptyString = ""
    
    static let playLevelTableCellIdentifier = "cell"
    static let loadTableCellIdentifier = "mycell"
    static let gameViewControllerIdentifier = "GameScreen"
    static let menuViewControllerIdentifier = "MenuScreen"
    static let playLevelViewControllerIdentifier = "PlayLevelScreen"
    static let levelDesignViewControllerIdentifier = "LevelDesignScreen"
    
    static let errorMessageFailedToRetrieveDocument = "Failed to retrieve files from documents directory"
    static let errorMessageFailedToDeleteFile = "Failed to delete file"
    static let errorMessageFailedToSaveFile = "Failed to save level design"
    static let loadTitle = "Load Level"
    static let saveTitle = "Save Level"
    static let loadMessage = "Choose a level to load"
    static let saveMessage = "Enter a name for your saved level"
    static let loadButtonTitle = "Load"
    static let saveButtonTitle = "Save"
    static let deleteButtonTitle = "Delete"
    static let cancelButtonTitle = "Cancel"

    static let contentViewControllerKey = "contentViewController"
    
    
    static let coderRowKey = "row"
    static let coderColKey = "col"
    static let coderColorKey = "color"
    static let coderPowerKey = "power"
    static let coderGridKey = "grid"
    
    // grid constants
    static let gridNumRows = 9
    static let gridNumColsForEvenRow = 12
    static let gridNumColsForOddRow = 11
    static let adjustRowSeparation = CGFloat(6.7/8)
    
    // physics constants
    static let timeStep = 1.0
    static let bubbleVelocity = 7.0
    
    static let numberOfRandomizedColours = UInt32(4)
    static let adjustCentre = 0.5
    static let adjustCentreForOddRow = 1
    
    static let startingLaunchAngle = M_PI/2
}

