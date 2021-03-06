//
//  PlayLevelViewController.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 28/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation
import UIKit

class PlayLevelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    private let documentDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    private var savedFileNames: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.playLevelTableCellIdentifier)
        tableView.rowHeight = 150.0
        
        let filemanager = NSFileManager()
        do {
            savedFileNames = try filemanager.contentsOfDirectoryAtPath(documentDirectory.path!)
        } catch {
            print(Constants.errorMessageFailedToRetrieveDocument)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedFileNames!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(Constants.loadTableCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: Constants.playLevelTableCellIdentifier)
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        cell!.textLabel?.adjustsFontSizeToFitWidth = true
        cell!.textLabel?.text = savedFileNames![indexPath.row]
        cell!.textLabel?.font = UIFont(name: Constants.playLevelTextFont, size: Constants.playLevelTextSize)
        return cell!
    }
    
    /// - returns color of a cell
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = savedFileNames!.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 0.5, green: val, blue: 1.0, alpha: 1.0)
    }
    
    /// sets the color of the cell
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    /// When play button is selected, it loads the data of the level chosen and starts game play
    @IBAction func playButtonSelected(sender: AnyObject) {
        let pathToSelectedCell = tableView.indexPathForSelectedRow
        if pathToSelectedCell != nil {
            let selectedFileName = tableView.cellForRowAtIndexPath(pathToSelectedCell!)?.textLabel?.text
            let loadedLevelData = getLevelData(selectedFileName!)
            let gameViewController = self.storyboard!.instantiateViewControllerWithIdentifier(Constants.gameViewControllerIdentifier) as! GameViewController
            loadedLevelData.removeAllEmptyBubbles()
            gameViewController.setGridData(loadedLevelData)
            gameViewController.setPreviousControllerIdentifier(Constants.playLevelViewControllerIdentifier)
            gameViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(gameViewController, animated: true, completion: nil)
        }
 
    }
    
    /// Selecting the back button leads back to the menu page
    @IBAction func backButtonSelected(sender: AnyObject) {
        let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier(Constants.menuViewControllerIdentifier)
        menuViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(menuViewController, animated: true, completion: nil)
    }
    
    /// Retrieves data of a level design
    private func getLevelData(fileName: String) -> BubbleGrid {
        let archiveURL = documentDirectory.URLByAppendingPathComponent("\(fileName)")
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(archiveURL.path!) as? BubbleGrid)!
    }
}