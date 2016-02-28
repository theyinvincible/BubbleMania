//
//  GameEngine.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 28/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation
import UIKit

class GameEngine {
    private var launchBubblePosition: (CGFloat, CGFloat) = (0, 0)
    private var angleOfLaunchedBubble = M_PI/2
    private var launchAngle = M_PI/2
    private var gridData: BubbleGrid
    private let viewFrame: CGRect
    
    private var launchBubble = ProjectileBubble(xPos: -1, yPos: -1)
    private var prelaunchBubbles = [ProjectileBubble]()
    private var numPrelaunchBubbles = 3;
    
    private var bubbleDiameter: CGFloat?
    private var currentFrame: UIView?
    private var renderer: Renderer
    private var bubbleIsLaunching = false
    private var physicsEngine: PhysicsEngine
    private var velocity: Double
    
    private var explodingFrames = 0
    private var lastSnappedBubble: GridBubble?
    private var bubblesToBeRemoved = [GridBubble]()
    
    init(gridData: BubbleGrid, viewFrame: CGRect) {
        // initialize values
        self.gridData = gridData
        self.viewFrame = viewFrame
        bubbleDiameter = viewFrame.size.width/CGFloat(Constants.gridNumColsForEvenRow)
        launchBubblePosition.0 = (viewFrame.width/2) - (bubbleDiameter!/2)
        launchBubblePosition.1 = viewFrame.height - bubbleDiameter!
        
        // initialize physics engine
        physicsEngine = PhysicsEngine(topBound: Double(viewFrame.minY), bottomBound: Double(viewFrame.height), leftBound: Double(viewFrame.minX), rightBound: Double(viewFrame.width))
        physicsEngine.setTimeStep(Constants.timeStep)
        physicsEngine.setReflectionOfProjectile(false, bottom: true, right: true, left: true)
        velocity = Constants.bubbleVelocity
        
        // initialize renderer
        renderer = Renderer(data: gridData, launchedBubble: launchBubble, frame: viewFrame)
        initLaunchBubbles()
        renderer.redrawProjectedTrajectory(angleOfLaunchedBubble)
        renderer.updateLaunchedBubble(launchBubble)
        renderer.updatePrelaunchBubbles(prelaunchBubbles)
    }
    
    /// updates the angle of the projected trajectory of the pre-launched projectile bubble
    func updateAngle(angle: Double) {
        launchAngle = angle
        renderer.redrawProjectedTrajectory(launchAngle)
    }
    
    /// launches the projectile bubble
    func launch() {
        if !bubbleIsLaunching {
            angleOfLaunchedBubble = launchAngle
            bubbleIsLaunching = true
        }
    }
    
    /// handles the interactions in the game
    /// - returns the view of the game screen according to the interactions
    func getView() -> UIView {
        handleGameLogic()
        return renderer.redraw()
    }
    
    /// handles the trajectory of launched bubble and the effects of bubble collision
    func handleGameLogic() {
        if bubbleIsLaunching {
            updateLaunchedBubblePosition()
            renderer.updateLaunchedBubble(launchBubble)
            if detectCollision() {
                let snappedBubble = snapBubble()
                bubbleIsLaunching = false
                updatePrelaunchBubbles()
                renderer.updatePrelaunchBubbles(prelaunchBubbles)
                let destroyedBubbles = getDestroyedBubbles(snappedBubble)
                renderer.updateGrid(snappedBubble, removedBubbles: destroyedBubbles)
            }
        }
    }
    
    /// - returns an array of bubbles that were removed following the collision of the
    /// launch bubble with the grid
    /// if the projectile bubble comes into contact with a power bubble, the resulting
    /// effect will only consider the effects of the power bubble, disregarding connected
    /// bubbles of the same color
    func getDestroyedBubbles(snapBubble: GridBubble) -> [GridBubble] {
        let bubblesRemovedByPower = getBubblesRemovedByPowerBubbles(snapBubble)
        if !bubblesRemovedByPower.isEmpty {
            bubblesToBeRemoved = bubblesRemovedByPower
        } else {
            bubblesToBeRemoved = getBubblesToBeRemoved(snapBubble)
        }
        return bubblesToBeRemoved
    }
    
    /**********************************/
    /******Handles launch bubbles******/
    /**********************************/
     
    /// initializes prelaunch bubbles to be previewed
    private func initLaunchBubbles() {
        for _ in 0..<numPrelaunchBubbles {
            prelaunchBubbles.append(generateLaunchBubble())
        }
        launchBubble = prelaunchBubbles.first!
    }
    
    /// replaces the original launchBubble with the next, and appends a new projectile bubble for preview
    private func updatePrelaunchBubbles() {
        if !prelaunchBubbles.isEmpty {
            prelaunchBubbles.removeFirst()
            prelaunchBubbles.append(generateLaunchBubble())
        }
        if !prelaunchBubbles.isEmpty {
            launchBubble = prelaunchBubbles.first!
        }
    }
    
    /// generates a projectile bubble of random colour
    private func generateLaunchBubble() -> ProjectileBubble {
        let randomInt = Int(arc4random_uniform(Constants.numberOfRandomizedColours)) + 1 //to match the rawValue range of BubbleColor
        let color = BubbleColor(rawValue: randomInt)
        let bubble = ProjectileBubble(xPos: Double(launchBubblePosition.0), yPos: Double(launchBubblePosition.1))
        bubble.setColor(color!)
        return bubble
    }
    
    /// Retrieves the next position of a bubble that has been launched
    private func updateLaunchedBubblePosition() {
        let xPos = launchBubble.getXPos()
        let yPos = launchBubble.getYPos()
        let diameter = Double(bubbleDiameter!)
        let newVector = physicsEngine.getNextPosition(xPos, srcY: yPos, width: diameter, height: diameter, angle: angleOfLaunchedBubble, velocity: velocity)
        launchBubble.updatePosition(newVector.xCoord, yPos: newVector.yCoord)
        angleOfLaunchedBubble = newVector.angle
    }
    
    /*********************************************************/
    /******Handles snapping of projectile bubble to grid******/
    /*********************************************************/
     
    /// Places launchedBubble into the grid cell closest to it and adds it into the grid
    /// - returns the launched bubble as a GridBubble
    private func snapBubble() -> GridBubble {
        // determine closest grid cell's coordinates
        let diameter = Double(bubbleDiameter!)
        let row = Int(floor((launchBubble.getYPos() + (diameter/2))/(Double(Constants.adjustRowSeparation) * diameter)))
        let col: Int
        if row%2 == 0 {
            col = Int(floor((launchBubble.getXPos() + (diameter/2))/diameter))
        } else {
            col = Int(floor(launchBubble.getXPos()/diameter))
        }
        
        // add a GridBubble with the same colour properties as launchBubble into the grid
        let addedBubble = GridBubble(row: row, col: col)
        addedBubble.setColor(launchBubble.getColor())
        gridData.addBubble(addedBubble)
        
        return addedBubble
    }
    
    /// Detects collision between launchBubble and the top wall/bubbles in the grid
    /// - returns value indicating whether there is collision
    private func detectCollision() -> Bool {
        // detect collision with top wall
        if launchBubble.getYPos() < Double(viewFrame.minY) {
            return true
        }
        
        // detect collision with bubbles in grid
        let bubblesInGrid = gridData.getBubbleArray()
        let diameter = Double(bubbleDiameter!)
        for bubble in bubblesInGrid {
            // get centre position of launchBubble
            let x1 = launchBubble.getXPos() + diameter/2
            let y1 = launchBubble.getYPos() + diameter/2
            let x2: Double
            // get centre position of bubble in grid
            if bubble.getRow()%2 == 0 {
                x2 = (Double(bubble.getCol()) + Constants.adjustCentre) * diameter
            } else {
                x2 = Double(bubble.getCol() + Constants.adjustCentreForOddRow) * diameter
            }
            let y2 = (Double(bubble.getRow()) + Constants.adjustCentre) * Double(Constants.adjustRowSeparation) * diameter
            
            if physicsEngine.circlesIntersect(x1, y1: y1, r1: diameter/2, x2: x2, y2: y2, r2: diameter/2) {
                return true
            }
        }
        return false
    }
    
    /************************************************/
    /******Handles collision with power bubbles******/
    /************************************************/
    
    /// retrieves the power bubbles that are adjacent to the snappedBubble and removes bubbles that
    /// were directly destroyed by the power bubbles, as well as floating bubbles that were a result of that
    /// - returns an array of all the bubbles that were removed when the bubble snapped into grid next to a power bubble
    private func getBubblesRemovedByPowerBubbles(snappedBubble: GridBubble) -> [GridBubble] {
        let directPowers = powerBubblesTouched(snappedBubble)
        var removedBubbles = [GridBubble]()
        for powerBubble in directPowers {
            removedBubbles.appendContentsOf(handlePowerBubble(powerBubble, snappedBubble: snappedBubble))
        }
        removeFromGridData(removedBubbles)
        // handle floating bubbles
        let floatingBubbles = findFloatingBubbles()
        removedBubbles.appendContentsOf(floatingBubbles)
        removeFromGridData(floatingBubbles)
        
        return removedBubbles
    }
    
    /// - returns an array of a bubble's adjacent power bubbles
    private func powerBubblesTouched(bubble: GridBubble) -> [GridBubble] {
        let neighbours = getNeighbours(bubble)
        var powerBubbleNeighbours = [GridBubble]()
        for neighbour in neighbours {
            if (neighbour.getPower() != BubblePower.none) && (neighbour.getPower() != BubblePower.indestructible) {
                powerBubbleNeighbours.append(neighbour)
            }
        }
        return powerBubbleNeighbours
    }
    
    /// - returns array of bubbles destroyed directly by a power bubble and chained effect
    private func handlePowerBubble(powerBubble: GridBubble, snappedBubble: GridBubble) -> [GridBubble] {
        var destroyedBubbles = [GridBubble]()
        switch powerBubble.getPower() {
        case BubblePower.lightning:
            destroyedBubbles = gridData.getBubblesInRow(powerBubble.getRow())
            let chainedBubbles = containsPowerBubble(destroyedBubbles)
            removeFromGridData(destroyedBubbles)
            if !chainedBubbles.isEmpty {
                for chainedBubble in chainedBubbles {
                    destroyedBubbles.appendContentsOf(handlePowerBubble(chainedBubble, snappedBubble: snappedBubble))
                }
            }
        case BubblePower.bomb:
            destroyedBubbles = getNeighbours(powerBubble)
            let chainedBubbles = containsPowerBubble(destroyedBubbles)
            removeFromGridData(destroyedBubbles)
            if !chainedBubbles.isEmpty {
                for chainedBubble in chainedBubbles {
                    destroyedBubbles.appendContentsOf(handlePowerBubble(chainedBubble, snappedBubble: snappedBubble))
                }
            }
        case BubblePower.star:
            destroyedBubbles = gridData.getBubblesOfColor(snappedBubble.getColor())
            let chainedBubbles = containsPowerBubble(destroyedBubbles)
            removeFromGridData(destroyedBubbles)
            if !chainedBubbles.isEmpty {
                for chainedBubble in chainedBubbles {
                    destroyedBubbles.appendContentsOf(handlePowerBubble(chainedBubble, snappedBubble: snappedBubble))
                }
            }
        default:
            break
        }
        destroyedBubbles.append(powerBubble)
        return destroyedBubbles
    }
    
    /// - returns whether an array of GridBubbles contain a power bubble
    private func containsPowerBubble(bubbleArray: [GridBubble]) -> [GridBubble] {
        var powerBubbles = [GridBubble]()
        for bubble in bubbleArray {
            powerBubbles.append(bubble)
        }
        return powerBubbles
    }
    
    /***************************************************/
    /******Handles collision with ordinary bubbles******/
    /***************************************************/
     
    /// If attachedBubble is connected to at least 2 other bubbles of the same colour, and is not connected to a 
    /// power bubble, all connected bubbles of the same colour, as well as floating bubbles, will be removed from 
    /// the grid
    /// - returns an array of all the bubbles that were removed
    private func getBubblesToBeRemoved(attachedBubble: GridBubble) -> [GridBubble] {
        var removedBubbles = [GridBubble]()
        let connectedBubbles = findClusterBubbles(attachedBubble, areSameColour: true, reset: true)
        if connectedBubbles.count < 3 {
            return removedBubbles
        }
        removedBubbles.appendContentsOf(connectedBubbles)
        removeFromGridData(connectedBubbles)
        
        // handle floating bubbles
        let floatingBubbles = findFloatingBubbles()
        removedBubbles.appendContentsOf(floatingBubbles)
        removeFromGridData(floatingBubbles)
        
        return removedBubbles
    }

    /// Finds all the floating bubbles in the grid
    /// A bubble is floating if the cluster attached to it does not contain a bubble from the top row
    /// - returns an array of floating bubbles found
    private func findFloatingBubbles() -> [GridBubble] {
        var floatingBubbles = [GridBubble]()
        resetMarkingOfBubbles()
        let bubbleArray = gridData.getBubbleArray()
        for bubble in bubbleArray {
            if !bubble.isMarked() {
                let cluster = findClusterBubbles(bubble, areSameColour: false, reset: true)
                var floating = true
                for clusterBubble in cluster {
                    if clusterBubble.getRow() == 0 {
                        floating = false
                    }
                }
                if floating {
                    floatingBubbles.appendContentsOf(cluster)
                }
            }
        }
        return floatingBubbles
    }
    
    /// Finds a cluster of all the bubbles (of the same colour or not) connected directly/indirectly to the start bubble
    /// - returns array of bubbles in the cluster found
    private func findClusterBubbles(startBubble: GridBubble, areSameColour: Bool, reset: Bool) -> [GridBubble] {
        if reset {
            resetMarkingOfBubbles()
        }
        
        var unvisitedBubbles = [GridBubble]()
        var currentBubble: GridBubble?
        var orderedElements = [GridBubble]()
        var neighbours: [GridBubble]
        unvisitedBubbles.append(startBubble)
        startBubble.mark()
        
        // using depth-first traversal
        while !unvisitedBubbles.isEmpty {
            currentBubble = unvisitedBubbles.removeLast()
            
            //add currentBubble's surrounding bubbles into unvisitedBubbles
            if areSameColour {
                neighbours = getNeighboursOfSameColour(currentBubble!)
            } else {
                neighbours = getNeighbours(currentBubble!)
            }
            for neighbour in neighbours {
                if !neighbour.isMarked() {
                    unvisitedBubbles.append(neighbour)
                    neighbour.mark()
                }
            }
            orderedElements.append(currentBubble!)
        }
        return orderedElements
    }
    
    /// resets all bubbles in gridData to an unmarked state
    private func resetMarkingOfBubbles() {
        for bubble in gridData.getBubbleArray() {
            bubble.unmark()
        }
    }
    
    /// - returns array of all direct neighbouring bubbles with the same colour as param bubble
    private func getNeighboursOfSameColour(bubble: GridBubble) -> [GridBubble] {
        let allNeighbours = getNeighbours(bubble)
        var sameColouredNeighbours = [GridBubble]()
        for neighbour in allNeighbours {
            if neighbour.getColor() == bubble.getColor() {
                sameColouredNeighbours.append(neighbour)
            }
        }
        return sameColouredNeighbours
    }
    
    /// - returns array of all direct neighbouring bubbles of param bubble
    private func getNeighbours(bubble: GridBubble) -> [GridBubble] {
        var neighbours = [GridBubble]()
        var start = 0
        if bubble.getRow()%2 == 0 {
            start--
        }
        // iterate through the row above, same row, and row below
        for (var rowOffset = -1; rowOffset < 2; rowOffset++) {
            let row = bubble.getRow() + rowOffset
            if !gridData.rowIsEmpty(row) {
                continue
            }
            
            if rowOffset != 0 { // neighbours from rows above and below
                for (var colOffset = start; colOffset < 2 + start; colOffset++) {
                    let col = bubble.getCol() + colOffset
                    if let neighbour = gridData.getBubble(row, col: col) {
                        neighbours.append(neighbour)
                    }
                }
            } else {    // left and right neighbours
                for (var colOffset = -1; colOffset < 2; colOffset += 2) {
                    let col = bubble.getCol() + colOffset
                    if let neighbour = gridData.getBubble(row, col: col) {
                        neighbours.append(neighbour)
                    }
                }
            }
        }
        return neighbours
    }
    
    /// Removes all items in param bubbles from the gridData
    private func removeFromGridData(bubbles: [GridBubble]) {
        for bubble in bubbles {
            gridData.removeBubble(bubble.getRow(), col: bubble.getCol())
        }
    }
}
