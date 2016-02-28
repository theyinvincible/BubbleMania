//
//  ViewController.swift
//  BubbleMania
//
//  Created by YangShun on 26/1/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

class LevelDesignViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var gameArea: UIView!
    @IBOutlet var palette: UIView!
    @IBOutlet var redBubble: UIButton!
    @IBOutlet var orangeBubble: UIButton!
    @IBOutlet var greenBubble: UIButton!
    @IBOutlet var blueBubble: UIButton!
    @IBOutlet var lightningBubble: UIButton!
    @IBOutlet var indestructibleBubble: UIButton!
    @IBOutlet var starBubble: UIButton!
    @IBOutlet var bombBubble: UIButton!
    @IBOutlet var eraser: UIButton!
    
    private var gridView: BubbleGridView?
    private var currentSelectedPalette: UIButton?
    
    private let documentDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    private var savedFileNames: [String]?

    private var drawingMode = DrawMode.unselected
    private var cellWidth: CGFloat?
    
    
    enum DrawMode: Int {
        case unselected, drawRed, drawOrange, drawGreen, drawBlue, drawLightning, drawIndestructible,
        drawStar, drawBomb, erase
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set touch gestures
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        gameArea.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        gameArea.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        longPressGesture.delegate = self
        gameArea.addGestureRecognizer(longPressGesture)
        
        // load background
        setBackgroundView()
        
        // load grid
        let frame = gameArea.frame
        gridView = BubbleGridView(frame: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        gameArea.addSubview(gridView!)

        //load palette
        setPaletteView()
    }

    /// Sets the background view of the level design
    private func setBackgroundView() {
        let backgroundImage = Constants.backgroundImage
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
                    updateBubbleCellView(selectedBubbleView!)
                }
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
        }
    }
    
    /// Sets the images of buttons in the palette view
    private func setPaletteView() {
        let paletteButtons = [redBubble, orangeBubble, greenBubble, blueBubble, lightningBubble,
            bombBubble, starBubble, indestructibleBubble, eraser]
        redBubble.setImage(Constants.redBubbleImage, forState: UIControlState.Normal)
        orangeBubble.setImage(Constants.orangeBubbleImage, forState: UIControlState.Normal)
        greenBubble.setImage(Constants.greenBubbleImage, forState: UIControlState.Normal)
        blueBubble.setImage(Constants.blueBubbleImage, forState: UIControlState.Normal)
        lightningBubble.setImage(Constants.lightningBubbleImage, forState: UIControlState.Normal)
        bombBubble.setImage(Constants.bombBubbleImage, forState: UIControlState.Normal)
        starBubble.setImage(Constants.starBubbleImage, forState: UIControlState.Normal)
        indestructibleBubble.setImage(Constants.indestructibleBubbleImage, forState: UIControlState.Normal)
        eraser.setImage(Constants.eraserImage, forState: UIControlState.Normal)
        for button in paletteButtons {
            button.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            button.alpha = 0.6
        }
    }
  
    /// Updates the view of the bubble touched according to the current drawing mode
    /// - returns the new color being set to the bubble
    private func updateBubbleCellView(selectedView: BubbleView) {
        switch drawingMode {
        case DrawMode.unselected:
            selectedView.setNextCycleColor() //for tap purposes
        case DrawMode.drawRed:
            selectedView.setColor(BubbleColor.red)
        case DrawMode.drawOrange:
            selectedView.setColor(BubbleColor.orange)
        case DrawMode.drawGreen:
            selectedView.setColor(BubbleColor.green)
        case DrawMode.drawBlue:
            selectedView.setColor(BubbleColor.blue)
        case DrawMode.erase:
            selectedView.setColor(BubbleColor.uninitalized)
        case DrawMode.drawLightning:
            selectedView.setPower(BubblePower.lightning)
        case DrawMode.drawBomb:
            selectedView.setPower(BubblePower.bomb)
        case DrawMode.drawIndestructible:
            selectedView.setPower(BubblePower.indestructible)
        case DrawMode.drawStar:
            selectedView.setPower(BubblePower.star)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonSelected(sender: AnyObject) {
        let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier(Constants.menuViewControllerIdentifier)
        menuViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(menuViewController, animated: true, completion: nil)
        
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
        } else if sender.isEqual(lightningBubble) {
            drawingMode = DrawMode.drawLightning
        } else if sender.isEqual(indestructibleBubble) {
            drawingMode = DrawMode.drawIndestructible
        } else if sender.isEqual(starBubble) {
            drawingMode = DrawMode.drawStar
        } else if sender.isEqual(bombBubble) {
            drawingMode = DrawMode.drawBomb
        } else if sender.isEqual(eraser) {
            drawingMode = DrawMode.erase
        }
        
        //handle deselection
        currentSelectedPalette?.alpha = Constants.unselectedAlpha
        if sender.isEqual(currentSelectedPalette) {
            drawingMode = DrawMode.unselected
            currentSelectedPalette = nil
        } else {
            //indicate mode that was selected
            currentSelectedPalette = sender as? UIButton
            currentSelectedPalette!.alpha = Constants.selectedAlpha
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
        var cell = tableView.dequeueReusableCellWithIdentifier(Constants.loadTableCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: Constants.loadTableCellIdentifier)
        }
        cell?.separatorInset = UIEdgeInsetsZero
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsetsZero
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        cell?.textLabel?.text = savedFileNames![indexPath.row]
        return cell!
    }
    
    @IBAction func startButtonSelected() {
        let gameEngineViewController = self.storyboard!.instantiateViewControllerWithIdentifier(Constants.gameViewControllerIdentifier) as! GameViewController
        let currentLevelDesign = convertDataToModel()
        currentLevelDesign.removeAllEmptyBubbles()
        gameEngineViewController.setGridData(currentLevelDesign)
        gameEngineViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(gameEngineViewController, animated: true, completion: nil)
    }
    
    /// Action performed when Reset button is selected
    /// Clears screen view and data
    @IBAction func resetButtonSelected() {
        gridView!.removeFromSuperview()
        let frame = gameArea.frame
        gridView = BubbleGridView(frame: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        gameArea.addSubview(gridView!)
    }
    
    /// Action performed when Load button is selected
    /// Displays list of previously saved files and reloads the view based on user's selection of file to be loaded
    @IBAction func loadButtonSelected() {
        // retrieve list of saved files
        let filemanager = NSFileManager()
        do {
            savedFileNames = try filemanager.contentsOfDirectoryAtPath(documentDirectory.path!)
        } catch {
            print(Constants.errorMessageFailedToRetrieveDocument)
        }
        
        // set view for showing list of saved files
        let alert = UIAlertController(title: Constants.loadTitle, message: Constants.loadMessage, preferredStyle: .Alert)
        let rect = CGRect(x: 0, y: 0, width: 272, height: alert.view.frame.height/4)
        let viewController = UIViewController()
        let tableViewOfSavedFiles = getTableViewOfSavedCells(viewController, rect: rect)
        alert.setValue(viewController, forKey: Constants.contentViewControllerKey)

        // set load, delete, and cancel actions in alert
        let loadAction = UIAlertAction(title: Constants.loadButtonTitle, style: .Default,  handler: {
            (action:UIAlertAction) -> Void in
            self.handleLoadTableLoadButton(tableViewOfSavedFiles)
        })
        
        let deleteAction = UIAlertAction(title: Constants.deleteButtonTitle, style: .Default) {
            (action: UIAlertAction) -> Void in
            self.handleLoadTableDeleteButton(tableViewOfSavedFiles, filemanager: filemanager)
        }
        let cancelAction = UIAlertAction(title: Constants.cancelButtonTitle, style: .Default) {
        (action: UIAlertAction) -> Void in
        }
        
        alert.addAction(loadAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /// Handles action for when load button is selected in the load table
    private func handleLoadTableLoadButton(tableViewOfSavedFiles: UITableView) {
        let pathToSelectedCell = tableViewOfSavedFiles.indexPathForSelectedRow
        if pathToSelectedCell != nil {
            let selectedFileName = tableViewOfSavedFiles.cellForRowAtIndexPath(pathToSelectedCell!)?.textLabel?.text
            let loadedLevelData = getLevelData(selectedFileName!)
            loadLevel(loadedLevelData)
        }
    }
    
    /// Handles action for when delete button is selected in the laod table
    private func handleLoadTableDeleteButton(tableViewOfSavedFiles: UITableView, filemanager: NSFileManager) {
        let pathToSelectedCell = tableViewOfSavedFiles.indexPathForSelectedRow
        if pathToSelectedCell != nil {
            let removedFileName = tableViewOfSavedFiles.cellForRowAtIndexPath(pathToSelectedCell!)?.textLabel?.text
            let pathToRemovedFile = self.documentDirectory.URLByAppendingPathComponent("\(removedFileName!)")
            do {
                try filemanager.removeItemAtPath(pathToRemovedFile.path!)
            } catch {
                print(Constants.errorMessageFailedToDeleteFile)
            }
        }
    }
    
    /// - Returns a table view of the saved level designs
    private func getTableViewOfSavedCells(viewController: UIViewController, rect: CGRect) -> UITableView {
        let tableViewOfSavedFiles = UITableView(frame: rect)
        tableViewOfSavedFiles.delegate = self
        tableViewOfSavedFiles.dataSource = self
        setLoadTableViewStyle(tableViewOfSavedFiles)
        
        viewController.preferredContentSize = rect.size
        viewController.view.addSubview(tableViewOfSavedFiles)
        viewController.view.bringSubviewToFront(tableViewOfSavedFiles)
        return tableViewOfSavedFiles
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
    private func loadLevel(levelData: BubbleGrid) {
        gridView!.removeFromSuperview()
        let frame = gameArea.frame
        gridView = BubbleGridView(frame: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        gameArea.addSubview(gridView!)
        gridView!.setGridDesign(levelData)
    }
    
    /// Retrieves data of a level design
    private func getLevelData(fileName: String) -> BubbleGrid {
        let archiveURL = documentDirectory.URLByAppendingPathComponent("\(fileName)")
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(archiveURL.path!) as? BubbleGrid)!
    }
    
    /// Takes in a file name and stores the level design's data into the path directory
    private func saveData(fileName: String) {
        let levelDesign = convertDataToModel()
        let archiveURL = documentDirectory.URLByAppendingPathComponent("\(fileName)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(levelDesign, toFile: archiveURL.path!)
        if !isSuccessfulSave {
            print(Constants.errorMessageFailedToSaveFile)
        }
    }
    
    /// converts and stores grid data into a level design object
    private func convertDataToModel() -> BubbleGrid {
        let bubbleViewArray = gridView!.getBubbleViewArray()
        let levelDesign = BubbleGrid()
        for bubbleView in bubbleViewArray {
            let bubble = GridBubble(row: bubbleView.getRow(), col: bubbleView.getCol())
            bubble.setColor(bubbleView.getColor())
            bubble.setPower(bubbleView.getPower())
            levelDesign.addBubble(bubble)
        }
        return levelDesign
    }
    
    /// Action performed when Save button is selected
    /// Current design will be saved with the file name input by user
    @IBAction func saveButtonSelected(sender: AnyObject) {
        let alert = UIAlertController(title: Constants.saveTitle, message: Constants.saveMessage, preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: Constants.saveButtonTitle, style: .Default,  handler: {
            (action:UIAlertAction) -> Void in
            let saveFileName = alert.textFields!.first!.text
            if saveFileName != Constants.emptyString {
                self.saveData(saveFileName!)
            }
        })
        
        let cancelAction = UIAlertAction(title: Constants.cancelButtonTitle, style: .Default) {
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

