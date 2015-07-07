//
//  SearchHistoryTableViewController.swift
//  Smashtag
//
//  Created by Brian Jewkes on 7/4/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class SearchHistoryTableViewController: UITableViewController {

    var searchHistory = [String]()
    
    
    
    //MARK: - ViewController Lifecycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let history = defaults.stringArrayForKey("searchHistory"){
            searchHistory = history as! [String]
            tableView.reloadData()
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return searchHistory.count
    }

    
    private struct Storyboard {
        static let SearchTermReuseIdentifier = "SearchTerm"
        static let TweetTableSegueIdentifier = "TweetTableSegue"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.SearchTermReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel!.text = searchHistory[indexPath.row]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as? UITableViewCell
        if sender?.identifier == Storyboard.TweetTableSegueIdentifier {
            if let navCon = segue.destinationViewController as? UINavigationController {
                if let destination = navCon.visibleViewController as? TweetTableViewController{
                    destination.searchText = cell?.textLabel!.text
                }
            }
        }
    }
}
