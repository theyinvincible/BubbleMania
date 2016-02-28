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
    private var renderer: newRenderer
    private var bubbleIsLaunching = false
    private var physicsEngine: PhysicsEngine
    private var velocity = 7.0
    
    private var explodingFrames = 0
    private var lastSnappedBubble: GridBubble?
    private var bubblesToBeRemoved = [GridBubble]()
    
    init(gridData: BubbleGrid, viewFrame: CGRect) {
        self.gridData = gridData
        self.viewFrame = viewFrame
        
        // initialize values
        bubbleDiameter = viewFrame.size.width/CGFloat(12)
        launchBubblePosition.0 = (viewFrame.width/2) - (bubbleDiameter!/2)
        launchBubblePosition.1 = viewFrame.height - bubbleDiameter!
        
        // initialize physics engine
        physicsEngine = PhysicsEngine(topBound: Double(viewFrame.minY), bottomBound: Double(viewFrame.height), leftBound: Double(viewFrame.minX), rightBound: Double(viewFrame.width))
        physicsEngine.setTimeStep(1.0)
        physicsEngine.setReflectionOfProjectile(false, bottom: true, right: true, left: true)
        
        // initialize renderer
        renderer = newRenderer(data: gridData, launchedBubble: launchBubble, frame: viewFrame)//Renderer(data: gridData, launchedBubble: launchBubble, frame: viewFrame, launchAngle: launchAngle, prelaunchBubbles: prelaunchBubbles)
        
        initLaunchBubbles()
        renderer.redrawProjectedTrajectory(angleOfLaunchedBubble)
        renderer.updateLaunchedBubble(launchBubble)
        renderer.updatePrelaunchBubbles(prelaunchBubbles)
    }
    
    func launch() {
        if !bubbleIsLaunching {
            angleOfLaunchedBubble = launchAngle
            bubbleIsLaunching = true
        }
    }
    
    func getView() -> UIView {
        logic()
        return renderer.redraw()
    }
        
    func logic() {
        if bubbleIsLaunching {
            updateLaunchedBubblePosition()
            renderer.updateLaunchedBubble(launchBubble)
            if detectCollision() {
                //lastSnappedBubble = snapBubble()
                let snappedBubble = snapBubble()
                bubbleIsLaunching = false
                updateLaunchBubbles()
                renderer.updatePrelaunchBubbles(prelaunchBubbles)
                let destroyedBubbles = getDestroyedBubbles(snappedBubble)
                print("passing removed bubbles to renderer")
                print(destroyedBubbles.isEmpty)
                renderer.updateGrid(snappedBubble, removedBubbles: destroyedBubbles)
            }
        }
    }
        
    func getDestroyedBubbles(snapBubble: GridBubble) -> [GridBubble] {
        let bubblesRemovedByPower = getBubblesRemovedWithPower(snapBubble)
        if !bubblesRemovedByPower.isEmpty {
            bubblesToBeRemoved = bubblesRemovedByPower
        } else {
            bubblesToBeRemoved = getBubblesToBeRemoved(snapBubble)      //this part takes too long
        }
        return bubblesToBeRemoved
    }
    
    func updateAngle(angle: Double) {
        launchAngle = angle
        renderer.redrawProjectedTrajectory(launchAngle)
        /// get renderer to redraw the dotted lines
    }
    
    /**********************************/
    /******Handles launch bubbles******/
    /**********************************/
    /// initializes launch bubbles
    func initLaunchBubbles() {
        for _ in 0..<numPrelaunchBubbles {
            prelaunchBubbles.append(generateLaunchBubble())
        }
        launchBubble = prelaunchBubbles.first!
    }
    /// removes the original launch bubble and appends a new projectile bubble
    func updateLaunchBubbles() {
        if !prelaunchBubbles.isEmpty {
            prelaunchBubbles.removeFirst()
            prelaunchBubbles.append(generateLaunchBubble())
        }
        if !prelaunchBubbles.isEmpty {
            launchBubble = prelaunchBubbles.first!
        }
    }
    /// generates and sets the launchBubble as a projectile bubble with a random colour
    func generateLaunchBubble() -> ProjectileBubble {
        let randomInt = Int(arc4random_uniform(4)) + 1
        let color = BubbleColor(rawValue: randomInt)
        let bubble = ProjectileBubble(xPos: Double(launchBubblePosition.0), yPos: Double(launchBubblePosition.1))
        bubble.setColor(color!)
        return bubble
    }
    /// Retrieves the next position of a bubble when it is launched
    func updateLaunchedBubblePosition() {
        let xPos = launchBubble.getXPos()
        let yPos = launchBubble.getYPos()
        let diameter = Double(bubbleDiameter!)
        let newCoords = physicsEngine.getNextPosition(xPos, srcY: yPos, width: diameter, height: diameter, angle: angleOfLaunchedBubble, velocity: velocity)
        launchBubble.updatePosition(newCoords.xCoord, yPos: newCoords.yCoord)
        angleOfLaunchedBubble = newCoords.angle
    }
    
    /*********************************************************/
    /******Handles snapping of projectile bubble to grid******/
    /*********************************************************/
    /// Places launcheBubble into the grid cell closest to it and adds it into the grid
    /// - returns the launched bubble as a GridBubble
    func snapBubble() -> GridBubble {
        // determine closest grid cell's coordinates
        let diameter = Double(bubbleDiameter!)
        let row = Int(floor((launchBubble.getYPos() + (diameter/2))/((6.7/8) * diameter)))
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
    func detectCollision() -> Bool {
        // detect collision with top wall
        if launchBubble.getYPos() < Double(viewFrame.minY) {//yCoordOfGridCorner {
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
                x2 = (Double(bubble.getCol()) + 0.5) * diameter
            } else {
                x2 = Double(bubble.getCol()+1) * diameter
            }
            let y2 = (Double(bubble.getRow()) + 0.5) * (6.7/8) * diameter
            
            if physicsEngine.circlesIntersect(x1, y1: y1, r1: diameter/2, x2: x2, y2: y2, r2: diameter/2) {
                return true
            }
        }
        return false
    }
    
    /************************************************/
    /******Handles collision with power bubbles******/
    /************************************************/
    func getBubblesRemovedWithPower(snappedBubble: GridBubble) -> [GridBubble] {
        let directPowers = powerBubblesTouched(snappedBubble)
        var removedBubbles = [GridBubble]()
        for powerBubble in directPowers {
            removedBubbles.appendContentsOf(handlePowerBubble(powerBubble, snappedBubble: snappedBubble))
            // need to remove from grid
        }
        removeFromGridData(removedBubbles)
        
        let floatingBubbles = findFloatingBubbles()
        removedBubbles.appendContentsOf(floatingBubbles)
        removeFromGridData(floatingBubbles)
        
        return removedBubbles
    }
    
    /// retrieve list of adjacent bubbles that have power
    func powerBubblesTouched(bubble: GridBubble) -> [GridBubble] {
        let neighbours = getNeighbours(bubble)
        var powerBubbleNeighbours = [GridBubble]()
        for neighbour in neighbours {
            if (neighbour.getPower() != BubblePower.none) && (neighbour.getPower() != BubblePower.indestructible) { //change to bubble.hasDestructivePower
                powerBubbleNeighbours.append(neighbour)
            }
        }
        return powerBubbleNeighbours
    }
    
    /// returns array of bubbles destroyed directly by a power bubble
    func handlePowerBubble(powerBubble: GridBubble, snappedBubble: GridBubble) -> [GridBubble] {
        var affectedBubbles = [GridBubble]()
        switch powerBubble.getPower() {
        case BubblePower.lightning:
            affectedBubbles = gridData.getBubblesInRow(powerBubble.getRow())
            // use recursion for chain reaction
            let chainedBubbles = containsPowerBubble(affectedBubbles)
            removeFromGridData(affectedBubbles)
            if !chainedBubbles.isEmpty {
                for chainedBubble in chainedBubbles {
                    affectedBubbles.appendContentsOf(handlePowerBubble(chainedBubble, snappedBubble: snappedBubble))
                }
            }
        case BubblePower.bomb:
            affectedBubbles = getNeighbours(powerBubble)
            let chainedBubbles = containsPowerBubble(affectedBubbles)
            removeFromGridData(affectedBubbles)
            if !chainedBubbles.isEmpty {
                for chainedBubble in chainedBubbles {
                    affectedBubbles.appendContentsOf(handlePowerBubble(chainedBubble, snappedBubble: snappedBubble))
                }
            }
        case BubblePower.star:
            affectedBubbles = gridData.getBubblesOfColor(snappedBubble.getColor())
            let chainedBubbles = containsPowerBubble(affectedBubbles)
            removeFromGridData(affectedBubbles)
            if !chainedBubbles.isEmpty {
                for chainedBubble in chainedBubbles {
                    affectedBubbles.appendContentsOf(handlePowerBubble(chainedBubble, snappedBubble: snappedBubble))
                }
            }
        default:
            break
        }
        affectedBubbles.append(powerBubble)
        return affectedBubbles
    }
    
    func containsPowerBubble(bubbleArray: [GridBubble]) -> [GridBubble] {
        var powerBubbles = [GridBubble]()
        for bubble in bubbleArray {
            powerBubbles.append(bubble)
        }
        return powerBubbles
    }
    
    /***************************************************/
    /******Handles collision with ordinary bubbles******/
    /***************************************************/
    /// If attachedBubble is connected to at least 2 other bubbles of the same colour,
    /// all connected bubbles of the same colour, as well as floating bubbles, will be removed from the grid
    /// - returns an array of all the bubbles that were removed
    func getBubblesToBeRemoved(attachedBubble: GridBubble) -> [GridBubble] {
        var removedBubbles = [GridBubble]()
        let connectedBubbles = findClusterBubbles(attachedBubble, areSameColour: true, reset: true)
        if connectedBubbles.count < 3 {
            return removedBubbles
        }
        removedBubbles.appendContentsOf(connectedBubbles)
        removeFromGridData(connectedBubbles)
        
        let floatingBubbles = findFloatingBubbles()
        removedBubbles.appendContentsOf(floatingBubbles)
        removeFromGridData(floatingBubbles)         // will there be error removing launchedBubble again
        
        return removedBubbles
    }

    /// Finds all the floating bubbles in the grid
    /// A bubble is floating if the cluster attached to it does not contain a bubble from the top row
    /// - returns an array of floating bubbles found
    func findFloatingBubbles() -> [GridBubble] {
        var floatingBubbles = [GridBubble]()
        resetMarkingOfBubbles()
        let bubbleArray = gridData.getBubbleArray()
        for bubble in bubbleArray {//gridData!.getBubbleArray() {
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
        // print("finished finding floating")
        return floatingBubbles
    }
    
    /// Finds a cluster of all the bubbles (of the same colour or not) connected directly/indirectly to it
    /// - returns array of bubbles in the cluster found
    func findClusterBubbles(startBubble: GridBubble, areSameColour: Bool, reset: Bool) -> [GridBubble] {
        if reset {
            resetMarkingOfBubbles()
        }
        
        var unvisitedBubbles = [GridBubble]() //FIFO
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
    
    // should put this in BubbleGrid
    func resetMarkingOfBubbles() {
        for bubble in gridData.getBubbleArray() {
            bubble.unmark()
        }
    }
    
    // should put this in BubbleGrid
    /// - returns array of all direct neighbouring bubbles with the same colour as param bubble
    func getNeighboursOfSameColour(bubble: GridBubble) -> [GridBubble] {
        let allNeighbours = getNeighbours(bubble)
        var sameColouredNeighbours = [GridBubble]()
        for neighbour in allNeighbours {
            if neighbour.getColor() == bubble.getColor() {
                sameColouredNeighbours.append(neighbour)
            }
        }
        return sameColouredNeighbours
    }
    
    // should put this in BubbleGrid
    /// - returns array of all direct neighbouring bubbles of param bubble
    func getNeighbours(bubble: GridBubble) -> [GridBubble] {
        var neighbours = [GridBubble]()
        var start = 0
        if bubble.getRow()%2 == 0 {
            start--
        }
        // iterate through the row above, same row, and row below
        for (var i = -1; i < 2; i++) {
            let row = bubble.getRow() + i
            if !gridData.rowIsEmpty(row) {
                continue
            }
            
            if i != 0 { // neighbours from rows above and below
                for (var j = start; j < 2 + start; j++) {
                    let col = bubble.getCol() + j
                    if let neighbour = gridData.getBubble(row, col: col) {
                        neighbours.append(neighbour)
                    }
                }
            } else {    // left and right neighbours
                for (var j = -1; j < 2; j += 2) {
                    let col = bubble.getCol() + j
                    if let neighbour = gridData.getBubble(row, col: col) {
                        neighbours.append(neighbour)
                    }
                }
            }
        }
        return neighbours
    }
    
    /// Removes all items in param bubbles from the gridData
    func removeFromGridData(bubbles: [GridBubble]) {
        for bubble in bubbles {
            gridData.removeBubble(bubble.getRow(), col: bubble.getCol())
        }
    }

}
