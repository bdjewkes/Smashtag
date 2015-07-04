//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Brian Jewkes on 7/1/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    let hashtagMentionColor = UIColor.grayColor()
    let userMentionColor = UIColor.redColor()
    let urlMentionColor = UIColor.blueColor()
    
    
    var tweet: Tweet? {
        didSet {
            
            tweet?.userMentions
            updateUI()
        }
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    func highlightMentionsInText(attributedText: NSMutableAttributedString, mentions: [Tweet.IndexedKeyword], color: UIColor) -> NSMutableAttributedString {
        for mention in mentions {
            attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
        }
        return attributedText	
    }
    
    func updateUI(){
        tweetProfileImageView?.image = nil
        tweetScreenNameLabel?.text = nil
        tweetTextLabel?.text = nil
        if let tweet = self.tweet {
            var attributedText = NSMutableAttributedString(string: tweet.text)
            attributedText = highlightMentionsInText(attributedText, mentions: tweet.userMentions, color: userMentionColor)
            attributedText = highlightMentionsInText(attributedText, mentions: tweet.hashtags, color: hashtagMentionColor)
            attributedText = highlightMentionsInText(attributedText, mentions: tweet.urls, color: urlMentionColor)
            tweetTextLabel?.attributedText = attributedText
        
            tweetScreenNameLabel?.text = "\(tweet.user)"
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL) { //blocks main thread, multithread here
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
        }
    }
}
