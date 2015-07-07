//
//  TweetTableViewController.swift
//  
//
//  Created by Brian Jewkes on 7/1/15.
//
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Model
    
    var tweets = [[Tweet]]()
    
    var searchText: String? = "#lovewins" {
        didSet {
            if let search = searchText {
                searchHistory.append(search)
            }
            searchTextField.text = searchText
            lastSuccessfulRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    var searchHistory = [String]() {
        didSet {
            if searchHistory.count > 100 {
                searchHistory.removeAtIndex(0)
            }
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(searchHistory, forKey: "searchHistory")
        }
    }
    
    
    
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let history = defaults.stringArrayForKey("searchHistory"){
            searchHistory = history as! [String]
        }
        refresh()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var lastSuccessfulRequest: TwitterRequest?

    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if let searchText = self.searchText{
                return TwitterRequest(search: searchText, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest?.requestForNewer
        }
    }
    
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt{
                request.fetchTweets { (newTweets)-> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                    }
                }
            }
        }
    }

    func refresh(){
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet{
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return tweets[section].count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
       
        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToTweetTableViewController(segue: UIStoryboardSegue){
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            if let destination = navCon.visibleViewController as? MentionsTableViewController
            {
                if let tweetCell = sender as? TweetTableViewCell {
                    destination.tweet = tweetCell.tweet
                }
                
            }
        }
                
        
    }
}
