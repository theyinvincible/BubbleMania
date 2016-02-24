//
//  ViewController.swift
//  LevelDesigner
//
//  Created by YangShun on 26/1/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var gameArea: UIView!
    @IBOutlet var palette: UIView!
    @IBOutlet var redBubble: UIButton!
    @IBOutlet var orangeBubble: UIButton!
    @IBOutlet var greenBubble: UIButton!
    @IBOutlet var blueBubble: UIButton!
    @IBOutlet var eraser: UIButton!
    
    private var gridView: BubbleGridView?
    private var currentSelectedPalette: UIButton?
    
    private let documentDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    private var savedFileNames: [String]?

//    private let numRows = Constants.gridNumRows
  //  private let numColsForEvenRow = Constants.gridNumColsForEvenRow
    //private let numColsForOddRow = Constants.gridNumColsForOddRow
    private var drawingMode = DrawMode.unselected
   // private var bubbleGridData = [UIView: BasicBubble]()
    private var cellWidth: CGFloat?
    
    
    enum DrawMode: Int {
        case unselected, drawRed, drawOrange, drawGreen, drawBlue, erase
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set touch gestures
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        gameArea.addGestureRecognizer(panGesture)           // pan gesture should be added to BubbleGridView

        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        gameArea.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        longPressGesture.delegate = self
        gameArea.addGestureRecognizer(longPressGesture)
        
        // load background
        setBackgroundView()
        
        // load grid
       // gridView = BubbleGridView(xPos: 0, yPos: 0, numRows: Constants.gridNumRows, numCols: Constants.gridNumColsForEvenRow, cellWidth: cellWidth!)
        let frame = gameArea.frame
        gridView = BubbleGridView(frame: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        gameArea.addSubview(gridView!)

        //load palette
        setPaletteView()
    }

    /// Sets the background view of the level design
    private func setBackgroundView() {
        let backgroundImage = UIImage(named: "background.png")  //put into constants
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea.addSubview(background)
    }
    
    /// Handles panning function according to drawingMode and updates models associated to the views touched
    func handlePan(panRecognizer: UIPanGestureRecognizer) {
        let panRecognizerView = panRecognizer.view
        let draggingPoint = panRecognizer.locationInView(panRecognizerView)
        let hitTest = UIView.hitTest(panRecognizerView!)
        let hitView = hitTest(draggingPoint, withEvent: nil)
        if hitView?.superview?.superview == panRecognizerView {
            if drawingMode != DrawMode.unselected {
                let selectedBubbleView = hitView as? BubbleView
                if selectedBubbleView != nil {
                    updateBubbleCellView(selectedBubbleView!)       //cannot use update bubble cell view
                }
               // let newBubbleColor = updateBubbleCellView(hitView!)
                //bubbleGridData[hitView!]?.setColor(newBubbleColor)
            }
        }
    }

    /// When a bubble view is tapped,
    ///  -> if drawingMode is unselected: color of the bubble is cycled
    ///  -> else: view of the bubble is updated according to drawingMode selected
    func handleTap(tapRecognizer: UITapGestureRecognizer) {
        let tapRecognizerView = tapRecognizer.view
        let tappedPoint = tapRecognizer.locationInView(tapRecognizerView)
        let hitTest = UIView.hitTest(tapRecognizerView!)
        let hitView = hitTest(tappedPoint, withEvent: nil)
        if hitView?.superview?.superview == tapRecognizerView {
            let selectedBubbleView = hitView as? BubbleView
            if selectedBubbleView != nil {
                updateBubbleCellView(selectedBubbleView!)
            }
        }
       // var newBubbleColor = BubbleColor.uninitalized
       // newBubbleColor = updateBubbleCellView(tappedView!)
        //bubbleGridData[tappedView!]?.setColor(newBubbleColor)
    }
    
    /// Handles long press, bubble cells which get long pressed will be erased
    func handleLongPress(longPressRecognizer: UILongPressGestureRecognizer) {
        let pressRecognizerView = longPressRecognizer.view
        let pressedView = longPressRecognizer.locationInView(pressRecognizerView)
        let hitTest = UIView.hitTest(pressRecognizerView!)
        let hitView = hitTest(pressedView, withEvent: nil)
        if hitView?.superview?.superview == pressRecognizerView {
            let selectedBubbleView = hitView as? BubbleView
            if selectedBubbleView != nil {
                selectedBubbleView!.setColor(BubbleColor.uninitalized)
            }
            //updateBubbleCellView(hitView as! BubbleView)
        }
  //      selectedView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
    //    bubbleGridData[selectedView!]!.setColor(BubbleColor.uninitalized)
    }
    
    /// Sets the images of buttons in the palette view
    private func setPaletteView() {
        let paletteButtons = [redBubble, orangeBubble, greenBubble, blueBubble, eraser]
        redBubble.setImage(Constants.redBubbleImage, forState: UIControlState.Normal)
        orangeBubble.setImage(Constants.orangeBubbleImage, forState: UIControlState.Normal)
        greenBubble.setImage(Constants.greenBubbleImage, forState: UIControlState.Normal)
        blueBubble.setImage(Constants.blueBubbleImage, forState: UIControlState.Normal)
        eraser.setImage(Constants.eraserImage, forState: UIControlState.Normal)
        for button in paletteButtons {
            button.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            button.alpha = 0.6
        }
    }
  
    /// Updates the view of the bubble touched according to the current drawing mode
    /// - returns the new color being set to the bubble
    private func updateBubbleCellView(selectedView: BubbleView) {
        var newBubbleColor: BubbleColor?
        switch drawingMode {
        case DrawMode.unselected:
            selectedView.setNextCycleColor()    // for tap purposes
        case DrawMode.drawRed:
            newBubbleColor = BubbleColor.red
        case DrawMode.drawOrange:
            newBubbleColor = BubbleColor.orange
        case DrawMode.drawGreen:
            newBubbleColor = BubbleColor.green
        case DrawMode.drawBlue:
            newBubbleColor = BubbleColor.blue
        case DrawMode.erase:
            newBubbleColor = BubbleColor.uninitalized
        }
        if newBubbleColor != nil {
            selectedView.setColor(newBubbleColor!)
        }
    //    return newBubbleColor!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Updates drawingMode accordingly when a button is selected/unselected from the palette
    @IBAction func drawingModeSelected(sender: AnyObject) {
        if sender.isEqual(redBubble) {
            drawingMode = DrawMode.drawRed
        } else if sender.isEqual(orangeBubble) {
            drawingMode = DrawMode.drawOrange
        } else if sender.isEqual(greenBubble) {
            drawingMode = DrawMode.drawGreen
        } else if sender.isEqual(blueBubble) {
            drawingMode = DrawMode.drawBlue
        } else if sender.isEqual(eraser) {
            drawingMode = DrawMode.erase
        }
        
        //handle deselection
        currentSelectedPalette?.alpha = 0.6
        if sender.isEqual(currentSelectedPalette) {
            drawingMode = DrawMode.unselected
            currentSelectedPalette = nil
        } else {
            //indicate mode that was selected
            currentSelectedPalette = sender as? UIButton
            currentSelectedPalette!.alpha = 1.0
        }
    }
        
    // - returns number of cells in table view of load alert (aka number of saved files)
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return savedFileNames!.count
    }
    
    // - returns cell containing the name of a saved file
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("mycell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell")
        }
        cell?.separatorInset = UIEdgeInsetsZero
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsetsZero
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        cell?.textLabel?.text = savedFileNames![indexPath.row]
        return cell!
    }
    
    @IBAction func startButtonSelected() {
        let gameEngineViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GameEngine") as! GameEngine
        /// REPEATED IN SAVELEVEL
      /**  var dataStorage = [Int: [Int: BasicBubble]]()
        for (var row = 0; row < numRows; row++) {
            dataStorage[row] = [Int: BasicBubble]()
        }
        for bubble in bubbleGridData.values {
            if bubble.getColor() != BubbleColor.uninitalized {
                dataStorage[bubble.getRow()]![bubble.getCol()] = bubble
            }
        }       ////    */
        let currentLevelDesign = convertDataToModel()
        gameEngineViewController.setGridDesign(currentLevelDesign)
        //gameEngineViewController.setLevelDesign(currentLevelDesign) //   gameEngineViewController.setGridData(currentLevelDesign)    //dataStorage)
      //  gameEngineViewController.viewDidLoad()
        self.presentViewController(gameEngineViewController, animated: true, completion: nil)
        //self.navigationController!.pushViewController(gameEngineViewController, animated: true)
    }
    
    /// Action performed when Reset button is selected
    /// Clears screen view and data
    @IBAction func resetButtonSelected() {
        gridView!.removeFromSuperview()
        //gridView = BubbleGridView(xPos: 0, yPos: 0, numRows: Constants.gridNumRows, numCols: Constants.gridNumColsForEvenRow, cellWidth: cellWidth!)
        let frame = gameArea.frame
        gridView = BubbleGridView(frame: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        gameArea.addSubview(gridView!)
    /**    let resetColor = BubbleColor.uninitalized
        for bubbleView in bubbleGridData.keys {
            setBubbleViewWithColor(bubbleView, color: resetColor)
            bubbleGridData[bubbleView]?.setColor(resetColor)
        }*/
    }
    
    /// Action performed when Load button is selected
    /// Displays list of previously saved files and reloads the view based on user's selection of file to be loaded
    @IBAction func loadButtonSelected() {
        // retrieve list of saved files
        let filemanager = NSFileManager()
        do {
            savedFileNames = try filemanager.contentsOfDirectoryAtPath(documentDirectory.path!)
        } catch {
            print("Failed to retrieve files from documents directory")
        }
        
        // set view for showing list of saved files
        let alert = UIAlertController(title: "Load Level", message: "Choose a level to load", preferredStyle: .Alert)
        let viewController = UIViewController()
        let rect = CGRect(x: 0, y: 0, width: 272, height: alert.view.frame.height/4)
        
        let tableViewOfSavedFiles = UITableView(frame: rect)
        tableViewOfSavedFiles.delegate = self
        tableViewOfSavedFiles.dataSource = self
        setLoadTableViewStyle(tableViewOfSavedFiles)
        
        viewController.preferredContentSize = rect.size
        viewController.view.addSubview(tableViewOfSavedFiles)
        viewController.view.bringSubviewToFront(tableViewOfSavedFiles)
        
        alert.setValue(viewController, forKey: "contentViewController")

        // set load, delete, and cancel actions in alert
        let loadAction = UIAlertAction(title: "Load", style: .Default,  handler: {
            (action:UIAlertAction) -> Void in
            let pathToSelectedCell = tableViewOfSavedFiles.indexPathForSelectedRow
            if pathToSelectedCell != nil {
                let selectedFileName = tableViewOfSavedFiles.cellForRowAtIndexPath(pathToSelectedCell!)?.textLabel?.text
                let loadedLevelData = self.getLevelData(selectedFileName!)
                self.loadLevel(loadedLevelData)
            }
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .Default) {
            (action: UIAlertAction) -> Void in
            let pathToSelectedCell = tableViewOfSavedFiles.indexPathForSelectedRow
            if pathToSelectedCell != nil {
                let removedFileName = tableViewOfSavedFiles.cellForRowAtIndexPath(pathToSelectedCell!)?.textLabel?.text
                let pathToRemovedFile = self.documentDirectory.URLByAppendingPathComponent("\(removedFileName!)")
                do {
                    try filemanager.removeItemAtPath(pathToRemovedFile.path!)
                } catch {
                    print("Failed to delete file \(removedFileName)")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
        (action: UIAlertAction) -> Void in
        }
        
        alert.addAction(loadAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /// Sets the style of the table view in Load alert
    private func setLoadTableViewStyle(tableView: UITableView) {
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.userInteractionEnabled = true
        tableView.allowsSelection = true
        tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    /// Loads the view corresponding to the data parameter
    private func loadLevel(levelData: LevelDesign) {    //[Int: [Int: BasicBubble]]) {
        // clears current view and data
     /**   for cellView in bubbleGridData.keys {
            cellView.removeFromSuperview()
        }
        bubbleGridData.removeAll()*/
        gridView!.removeFromSuperview()
     //   gridView = BubbleGridView(xPos: 0, yPos: 0, numRows: Constants.gridNumRows, numCols: Constants.gridNumColsForEvenRow, cellWidth: self.cellWidth!)
        let frame = gameArea.frame
        gridView = BubbleGridView(frame: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        gameArea.addSubview(gridView!)

    /**    let bubbleViewArray = gridView!.getBubbleViewArray()
        for bubbleView in bubbleViewArray {
            let bubbleData = levelData.getBubble(bubbleView.getRow(), col: bubbleView.getCol())
            bubbleView.setColor(bubbleData!.getColor())
        }*/
        
        gridView!.setGridDesign(levelData)

      /**  var numCols: Int
        var offsetX = CGFloat(0)
        var offsetY = CGFloat(20)
        let cellWidth = gameArea.frame.size.width/CGFloat(numColsForEvenRow)
        let cellHeight = cellWidth
        for (var row = 0; row < numRows; row++) {
       
            if row%2 == 0 {
                numCols = numColsForEvenRow
                offsetX = 0
            } else {
                numCols = numColsForOddRow
                offsetX = cellWidth/2
            }
            
            for (var col = 0; col < numCols; col++) {
                //create circular view of bubble cell
                let bubbleCell = UIView(frame: CGRectMake(offsetX, offsetY, cellWidth, cellHeight))
                initBubbleCellView(bubbleCell)
                gameArea.addSubview(bubbleCell)
                
                let savedBubbleData = levelData[row]![col]
                bubbleGridData[bubbleCell] = levelData[row]![col]
                setBubbleViewWithColor(bubbleCell, color: (savedBubbleData?.getColor())!)
                
                //set touch gestures
                let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
                tapGesture.delegate = self
                bubbleCell.addGestureRecognizer(tapGesture)
                
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
                longPressGesture.delegate = self
                bubbleCell.addGestureRecognizer(longPressGesture)
                
                offsetX += cellWidth
            }
            //adjust cell's y offset so that rows are touching each other
            offsetY += (7/8) * cellHeight
        }*/
    }
    
    /// Retrieves data of a level design
    private func getLevelData(fileName: String) -> LevelDesign {    //[Int: [Int: BasicBubble]]{
        let archiveURL = documentDirectory.URLByAppendingPathComponent("\(fileName)")
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(archiveURL.path!) as? LevelDesign)! //[Int: [Int: BasicBubble]])!
    }
    
    /// Takes in a file name and stores the level design's data into the path directory
    private func saveData(fileName: String) {
        let levelDesign = convertDataToModel()
        let archiveURL = documentDirectory.URLByAppendingPathComponent("\(fileName)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(levelDesign, toFile: archiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save level design")
        }
        /**var dataStorage = [Int: [Int: BasicBubble]]()
        
        for (var row = 0; row < numRows; row++) {
            dataStorage[row] = [Int: BasicBubble]()
        }
        for bubble in bubbleGridData.values {
            dataStorage[bubble.getRow()]![bubble.getCol()] = bubble
        }
        
        let archiveURL = documentDirectory.URLByAppendingPathComponent("\(fileName)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(dataStorage, toFile: archiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save level design")
        }*/
    }
    
    /// converts and stores grid data into a level design object
    private func convertDataToModel() -> LevelDesign {
        let bubbleViewArray = gridView!.getBubbleViewArray()
        let levelDesign = LevelDesign()
        for bubbleView in bubbleViewArray {
            let bubble = BasicBubble(row: bubbleView.getRow(), col: bubbleView.getCol())
            bubble.setColor(bubbleView.getColor())
            levelDesign.addBubble(bubble)
        }
        return levelDesign
    }
    
    /// Action performed when Save button is selected
    /// Current design will be saved with the file name input by user
    @IBAction func saveButtonSelected(sender: AnyObject) {
        let alert = UIAlertController(title: "Save Level", message: "Enter a name for your saved level", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default,  handler: {
            (action:UIAlertAction) -> Void in
            let saveFileName = alert.textFields!.first!.text
            if saveFileName != "" {
                self.saveData(saveFileName!)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

