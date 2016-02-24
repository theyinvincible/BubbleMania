//
//  GameEngine.swift
//  LevelDesigner
//
//  Created by Jing Yin Ong on 12/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import UIKit
import Darwin

class GameEngine: UIViewController, UIGestureRecognizerDelegate {
    private var launchBubblePosition: [CGFloat] = [0, 0]
    private var angleOfLaunchedBubble = M_PI/2
    private var launchAngle = M_PI/2
    private var gridData: LevelDesign?//[Int: [Int: BasicBubble]]?
    @IBOutlet weak var LaunchButton: UIButton!
    private var launchBubble = ProjectileBubble(xPos: -1, yPos: -1, hasPower: false)
    
    private var bubbleDiameter: CGFloat?
    private var currentFrame: UIView?
    private var renderer: Renderer?
    private var bubbleIsLaunching = false
    private var physicsEngine: PhysicsEngine?
    private var velocity = 7.0
    private let yCoordOfGridCorner = 20.0
    private let xCoordOfGridCorner = 0.0
    
    private var explodingFrames = 0
    private var lastSnappedBubble: BasicBubble?
    private var bubblesToBeRemoved = [BasicBubble]()
    
  //  func setGridData(gridData: [Int: [Int: BasicBubble]]) {
    //    self.gridData = gridData
    //}
    func setGridDesign(gridDesign: LevelDesign) {
        gridData = gridDesign
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // initialize values
        bubbleDiameter = self.view.frame.size.width/CGFloat(12)
        launchBubblePosition[0] = (self.view.frame.width/2) - (bubbleDiameter!/2)
        launchBubblePosition[1] = self.view.frame.height - bubbleDiameter!
        
        // set gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        generateLaunchBubble()
        
        // initialize physics engine
        physicsEngine = PhysicsEngine(topBound: yCoordOfGridCorner, bottomBound: Double(self.view.frame.height), leftBound: xCoordOfGridCorner, rightBound: Double(self.view.frame.width))
        physicsEngine!.setTimeStep(1.0)
        physicsEngine!.setReflectionOfProjectile(false, bottom: true, right: true, left: true)
        
        // draws initial scene
        renderer = Renderer(data: gridData!.getBubbleArray(), launchedBubble: launchBubble, frame: self.view.frame, launchAngle: launchAngle)
        currentFrame = renderer!.redraw()
        self.view.addSubview(currentFrame!)
        self.view.bringSubviewToFront(LaunchButton)
        
        // redraws scene at 60 frames per second
        var timer = NSTimer.scheduledTimerWithTimeInterval(1/60, target: self, selector: "updateView", userInfo: nil, repeats: true)
    }
    
    /// updates positions of objects and renders the frame accordingly
    func updateView() {
        currentFrame?.removeFromSuperview()
        var gridIsChanged = false
        
        // following the addition of launchBubble to the grid, retrieve bubbles to be removed, if any
        if lastSnappedBubble != nil {
            if gridData!.containsBubble(lastSnappedBubble!.getRow(), col: lastSnappedBubble!.getCol()) {
                bubblesToBeRemoved = getBubblesToBeRemoved(lastSnappedBubble!)
                if !bubblesToBeRemoved.isEmpty {
                    gridIsChanged = true
                    explodingFrames = 10    // number of frames for displaying explosion effect
                }
            }
      /**      if gridData!.keys.contains(lastSnappedBubble!.getRow()) {
                if gridData![lastSnappedBubble!.getRow()]!.keys.contains(lastSnappedBubble!.getCol()) {
                    bubblesToBeRemoved = getBubblesToBeRemoved(lastSnappedBubble!)
                    if !bubblesToBeRemoved.isEmpty {
                        gridIsChanged = true
                        explodingFrames = 10    // number of frames for displaying explosion effect
                    }
                }
            }*/
        }

        // update launch bubble position and react to collisions
        if bubbleIsLaunching {
            updateLaunchedBubblePosition()
            if detectCollision() {
                lastSnappedBubble = snapBubble()
                bubbleIsLaunching = false
                generateLaunchBubble()
                gridIsChanged = true
            }
        }
        
        if explodingFrames > 0 {
            explodingFrames--
            if explodingFrames == 0 {
                bubblesToBeRemoved.removeAll()
            }
        }
        
        // redraw scene
        if gridIsChanged {
            renderer!.update(gridData!.getBubbleArray() , launchedBubble: launchBubble, removedBubbles: bubblesToBeRemoved, launchAngle: launchAngle)
        } else {
            renderer!.update(launchBubble, removedBubbles: bubblesToBeRemoved, launchAngle: launchAngle)
        }
        
        currentFrame = renderer!.redraw()
        self.view.addSubview(currentFrame!)
        self.view.bringSubviewToFront(LaunchButton)
    }
    
    /// generates and sets the launchBubble as a projectile bubble with a random colour
    func generateLaunchBubble() {
        let randomInt = Int(arc4random_uniform(4)) + 1
        let color = BubbleColor(rawValue: randomInt)
        launchBubble = ProjectileBubble(xPos: Double(launchBubblePosition[0]), yPos: Double(launchBubblePosition[1]), hasPower: false)
        launchBubble.setColor(color!)
    }

    /// Handles launch button, launches the projectile bubble launchBubble
    @IBAction func launchBubble(sender: AnyObject?) {
        // nothing happens if a bubble is in the air
        if !bubbleIsLaunching {
            angleOfLaunchedBubble = launchAngle
            bubbleIsLaunching = true
        }
    }
    
    /// Places launcheBubble into the grid cell closest to it and adds it into the grid
    /// - returns the launched bubble as a BasicBubble
    func snapBubble() -> BasicBubble {
        // determine closest grid cell's coordinates
        let diameter = Double(bubbleDiameter!)
        let row = Int(floor((launchBubble.getYPos() + (diameter/2) - yCoordOfGridCorner)/((6.7/8) * diameter)))
        let col: Int
        if row%2 == 0 {
            col = Int(floor((launchBubble.getXPos() + (diameter/2))/diameter))
        } else {
            col = Int(floor(launchBubble.getXPos()/diameter))
        }
        
        // add a BasicBubble with the same colour properties as launchBubble into the grid
        let addedBubble = BasicBubble(row: row, col: col)
        addedBubble.setColor(launchBubble.getColor())
        
        gridData!.addBubble(addedBubble)
       /** if !gridData!.keys.contains(row) {
            gridData![row] = [Int: BasicBubble]()
        }
        gridData![row]![col] = addedBubble*/
        
        return addedBubble
    }
    
    /// Detects collision between launchBubble and the top wall/bubbles in the grid
    /// - returns value indicating whether there is collision
    func detectCollision() -> Bool {
        // detect collision with top wall
        if launchBubble.getYPos() < yCoordOfGridCorner {
            return true
        }
        
        // detect collision with bubbles in grid
        let bubblesInGrid = gridData!.getBubbleArray()
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
            let y2 = (Double(bubble.getRow()) + 0.5) * (6.7/8) * diameter + yCoordOfGridCorner
            
            if physicsEngine!.circlesIntersect(x1, y1: y1, r1: diameter/2, x2: x2, y2: y2, r2: diameter/2) {
                return true
            }
        }
        return false
    }
    
    /// Retrieves the next position of a bubble when it is launched
    func updateLaunchedBubblePosition() {
        let xPos = launchBubble.getXPos()
        let yPos = launchBubble.getYPos()
        let diameter = Double(bubbleDiameter!)
        let newCoords = physicsEngine!.getNextPosition(xPos, srcY: yPos, width: diameter, height: diameter, angle: angleOfLaunchedBubble, velocity: velocity)
        launchBubble.updatePosition(newCoords.xCoord, yPos: newCoords.yCoord)
        angleOfLaunchedBubble = newCoords.angle
    }
    
    /// If attachedBubble is connected to at least 2 other bubbles of the same colour, 
    /// all connected bubbles of the same colour, as well as floating bubbles, will be removed from the grid
    /// - returns an array of all the bubbles that were removed
    func getBubblesToBeRemoved(attachedBubble: BasicBubble) -> [BasicBubble] {
        var removedBubbles = [BasicBubble]()
        let connectedBubbles = findClusterBubbles(attachedBubble, areSameColour: true)
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
    
    /// Removes all items in param bubbles from the gridData
    func removeFromGridData(bubbles: [BasicBubble]) {
        for bubble in bubbles {
            gridData!.removeBubble(bubble.getRow(), col: bubble.getCol())
           /** if gridData!.keys.contains(bubble.getRow()) {
                gridData![bubble.getRow()]!.removeValueForKey(bubble.getCol())
            }*/
        }
    }
    
    /// Finds all the floating bubbles in the grid
    /// A bubble is floating if the cluster attached to it does not contain a bubble from the top row
    /// - returns an array of floating bubbles found
    func findFloatingBubbles() -> [BasicBubble] {
        var floatingBubbles = [BasicBubble]()
        for bubble in gridData!.getBubbleArray() {
            floatingBubbles.append(bubble)
            let cluster = findClusterBubbles(bubble, areSameColour: false)
            for clusterBubble in cluster {
                if clusterBubble.getRow() == 0 {
                    floatingBubbles.removeLast()
                    break
                }
            }
        }
        return floatingBubbles
    }
    
    /// Finds a cluster of all the bubbles (of the same colour or not) connected directly/indirectly to it
    /// - returns array of bubbles in the cluster found
    func findClusterBubbles(startBubble: BasicBubble, areSameColour: Bool) -> [BasicBubble] {
        var unvisitedBubbles = [BasicBubble]() //FIFO
        var visited = [BasicBubble]()
        var currentBubble: BasicBubble?
        var orderedElements = [BasicBubble]()
        var neighbours: [BasicBubble]
        unvisitedBubbles.append(startBubble)
        
        // using depth-first traversal
        while !unvisitedBubbles.isEmpty {
            currentBubble = unvisitedBubbles.removeFirst()
            visited.append(currentBubble!)
            
            //add currentBubble's surrounding bubbles into unvisitedBubbles
            if areSameColour {
                neighbours = getNeighboursOfSameColour(currentBubble!)
            } else {
                neighbours = getNeighbours(currentBubble!)
            }
            for neighbour in neighbours {
                if !visited.contains(neighbour) && !unvisitedBubbles.contains(neighbour) {
                    unvisitedBubbles.append(neighbour)
                }
            }
            orderedElements.append(currentBubble!)
        }
        return orderedElements
    }
    
    /// - returns array of all direct neighbouring bubbles with the same colour as param bubble
    func getNeighboursOfSameColour(bubble: BasicBubble) -> [BasicBubble] {
        let allNeighbours = getNeighbours(bubble)
        var sameColouredNeighbours = [BasicBubble]()
        for neighbour in allNeighbours {
            if neighbour.getColor() == bubble.getColor() {
                sameColouredNeighbours.append(neighbour)
            }
        }
        return sameColouredNeighbours
    }
    
    /// - returns array of all direct neighbouring bubbles of param bubble
    func getNeighbours(bubble: BasicBubble) -> [BasicBubble] {
        var neighbours = [BasicBubble]()
        var start = 0
        if bubble.getRow()%2 == 0 {
            start--
        }
        // iterate through the row above, same row, and row below
        for (var i = -1; i < 2; i++) {
            let row = bubble.getRow() + i
            if !gridData!.rowIsEmpty(row) {//!gridData!.keys.contains(row) {
                continue
            }
            
            if i != 0 { // neighbours from rows above and below
                for (var j = start; j < 2 + start; j++) {
                    let col = bubble.getCol() + j
                    if let neighbour = gridData?.getBubble(row, col: col) {
                        neighbours.append(neighbour)
                    }
             //       if gridData![row]!.keys.contains(col) {
               //         neighbours.append(gridData![row]![col]!)
                 //   }
                }
            } else {    // left and right neighbours
                for (var j = -1; j < 2; j += 2) {
                    let col = bubble.getCol() + j
                    if let neighbour = gridData?.getBubble(row, col: col) {
                        neighbours.append(neighbour)
                    }
              //      if gridData![row]!.keys.contains(col) {
                //        neighbours.append(gridData![row]![col]!)
                  //  }
                }
            }
        }
        return neighbours
    }

    /// - returns an array of all the bubbles in grid
/**    func getBubbleArray() -> [BasicBubble] {
        var bubbleData = [BasicBubble]()
        for dict in (gridData?.values)! {
            for bubble in dict.values {
                bubbleData.append(bubble)
            }
        }
        return bubbleData
    }*/
    
    /// handles tap gesture on game area for selection of angle
    func handleTap(tapRecognizer: UITapGestureRecognizer) {
        let point = tapRecognizer.locationInView(self.view)
        let changeX = point.x - (self.view.frame.width)/2
        let changeY = (self.view.frame.height) - point.y
        let gradient = Double(changeY/changeX)
        launchAngle = atan(gradient)
        if launchAngle < 0 {
            launchAngle += M_PI
        }
    }
}


