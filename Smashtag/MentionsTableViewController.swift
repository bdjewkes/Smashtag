//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Brian Jewkes on 7/2/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class MentionsTableViewController: UITableViewController {

    
    //MARK: Model
    
    var tweet: Tweet?{
        didSet {
            tweetImageData = [:]
            tweetMentions.append(tweetSection.Media(tweet!.media))
            tweetMentions.append(tweetSection.UserMentions(tweet!.userMentions))
            tweetMentions.append(tweetSection.Hashtags(tweet!.hashtags))
            tweetMentions.append(tweetSection.URLs(tweet!.urls))
            if(tweet?.media.count > 0){
                var images = [UIImage?]()
                for media in tweet!.media{
                    //Dispatch to another thread
                    tweetImageData[media.url] = nil
                    fetchTweetImage(media.url)
                }
            }
        }
    }
    
    var tweetMentions = [tweetSection]()
    
    enum tweetSection: Printable {
        case Media([MediaItem])
        case UserMentions([Tweet.IndexedKeyword])
        case Hashtags([Tweet.IndexedKeyword])
        case URLs([Tweet.IndexedKeyword])
        
        var description: String {
            var desc: String
            switch self{
            case .Media(_):
                return self.count > 0 ? "Media" : ""
            case .UserMentions(_):
                return self.count > 0 ? "Users" : ""
            case .Hashtags(_):
                return self.count > 0 ? "Hashtags" : ""
            case .URLs(_):
                return self.count > 0 ? "Links" : ""
            }
        }
        var count: Int{
            get{
                switch self{
                case .Media(let mentions):
                    return mentions.count
                case .UserMentions(let mentions):
                    return mentions.count
                case .Hashtags(let mentions):
                    return mentions.count
                case .URLs(let mentions):
                    return mentions.count
                }
            }
        }
        var data: (indexedKeywords: [Tweet.IndexedKeyword]?, mediaItems: [MediaItem]?){
            get{
                switch self{
                case .Media(let mentions):
                    return (nil, mentions)
                case .UserMentions(let mentions):
                    return (mentions, nil)
                case .Hashtags(let mentions):
                    return (mentions, nil)
                case .URLs(let mentions):
                    return (mentions, nil)
                }
            }
        }
    }
    var tweetImageData = [NSURL:UIImage?]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func fetchTweetImage(url: NSURL){
        var fetchedImage: UIImage? = nil
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
            let imageData = NSData(contentsOfURL: url) //
            dispatch_async(dispatch_get_main_queue()) {
                if imageData != nil {
                    fetchedImage = UIImage(data: imageData!)
                    self.tweetImageData[url] = fetchedImage
                }
            }
        }
    }
        
    // MARK: - Table view data source

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweetMentions.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return tweetMentions[section].description
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetMentions[section].count
    }
    
    struct Storyboard {
        static let IndexedKeywordCellReuseIdentifer = "IndexedKeywordMention"
        static let MediaMentionCellReuseIdentifier = "MediaMention"
        static let IndexKeywordMentionDetailSegueIdentifier = "Unwind Segue"
        static let MediaMentionDetailSegueIdentifier = "MediaMentionSegue"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var data = tweetMentions[indexPath.section].data
        if let stringData = data.indexedKeywords {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IndexedKeywordCellReuseIdentifer, forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel!.text = stringData[indexPath.row].keyword
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MediaMentionCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
            if let imageData = data.mediaItems  {
                if let image = tweetImageData[tweet!.media[indexPath.row].url] {
                    cell.imageView!.image = image
                }
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tweetMentions[indexPath.section].description == tweetSection.Media(tweet!.media).description {
            let imagePath = tweetImageData[tweet!.media[indexPath.row].url]
            if let imageData = imagePath  {
                //set row height to the image height, or the largest height that fits in the tableView's width bound
                //Currently using an arbirtrary value to space right side of the image off the edge of the tableView. Find a constant
                if let image = imageData {
                    return min(image.size.height, (tableView.bounds.width - 25) / CGFloat(tweet!.media[indexPath.row].aspectRatio))

                }
            }
        }
        return UITableViewAutomaticDimension
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let cell = sender as? UITableViewCell{
            let indexPath = tableView.indexPathForCell(cell)
            //IndexedKeyword segues: Hashtags, Usernames, and web addresses
            if segue.identifier == Storyboard.IndexKeywordMentionDetailSegueIdentifier{
                //Open web addresses in the browser, possible refator to segue to a UIWebView
                if tweetMentions[indexPath!.section].description == tweetSection.URLs(tweet!.urls).description{
                    UIApplication.sharedApplication().openURL(NSURL(string: tweet!.urls[indexPath!.row].keyword)!)
                } else {
                    //All other cases go to a TweetTableViewController
                    if let navCon = destination as? UINavigationController {
                        if let destination = navCon.visibleViewController as? TweetTableViewController
                        {
                            destination.searchText = cell.textLabel!.text
                        }
                    } else {
                        if let ttvc = destination as? TweetTableViewController{
                            ttvc.searchText = cell.textLabel!.text
                        }
                    }
                }
            } else if segue.identifier == Storyboard.MediaMentionDetailSegueIdentifier {
                if let navCon = destination as? UINavigationController{
                    if let destination = navCon.visibleViewController as? ImageViewController {
                        if let image = cell.imageView?.image{
                            //pass the image along so that the ImageViewController doesn't have to download it again
                            destination.image = image
                        }
                        //Pass along the MediaItem data for aspect ratio and url. Refactor to be more generic, and for better model encapsulaiton
                        destination.imageData = tweet!.media[indexPath!.row]
                    }
                }
            }
        }
    }
}

