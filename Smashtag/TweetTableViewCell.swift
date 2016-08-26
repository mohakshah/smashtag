//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Mohak Shah on 22/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    // model
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    // view outlets
    @IBOutlet weak var tweetBody: UILabel!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userDP: UIImageView!
    @IBOutlet weak var tweetTime: UILabel!
    
    private let secondsSinceLastDay: NSTimeInterval = 24 * 60 * 60 * -1
    
    // constants for the colors used to highlight items in a tweet
    private struct highlightColors {
        static let hashtags = UIColor.purpleColor()
        static let urls = UIColor.blueColor()
        static let mentions = UIColor(red: 0.254, green: 0.648, blue: 0.07, alpha: 1)
    }
    
    private func updateUI() {
        tweetBody?.text = nil
        userHandle?.text = nil
        userDP?.image = nil
        tweetTime?.text = nil
        
        if let tweet = self.tweet {
            // set the user handle
            userHandle.text = "@\(tweet.user.screenName)"
            
            // set the body of the tweet
            let attributedBody = NSMutableAttributedString(string: tweet.text)
            
            // format hashtags
            for ht in tweet.hashtags {
                attributedBody.addAttribute(NSForegroundColorAttributeName, value: highlightColors.hashtags, range: ht.nsrange)
            }
            
            // format urls
            for url in tweet.urls {
                attributedBody.addAttribute(NSForegroundColorAttributeName, value: highlightColors.urls, range: url.nsrange)
            }
            
            // format mentions
            for mention in tweet.userMentions {
                attributedBody.addAttribute(NSForegroundColorAttributeName, value: highlightColors.mentions, range: mention.nsrange)
            }
            
            tweetBody.attributedText = attributedBody
            
            // indicate pictures
            tweetBody.text?.appendContentsOf(" 📷(\(tweet.media.count))")
            
            // set a well-formatted date
            let dateFormatter = NSDateFormatter()
            
            if tweet.created.timeIntervalSinceNow > secondsSinceLastDay {
                dateFormatter.timeStyle = .ShortStyle
            } else {
                dateFormatter.dateStyle = .ShortStyle
            }
            
            // set a background task to fetch the user's display image
            if let dpURL = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    // fetch the image
                    if let imageData = NSData(contentsOfURL: dpURL) {
                        // move to the main queue
                        dispatch_async(dispatch_get_main_queue()) { [weak weakSelf = self] in
                            // make sure the cell has not been reused
                            if weakSelf?.tweet?.user.profileImageURL == dpURL {
                                weakSelf?.userDP.image = UIImage(data: imageData)
                            }
                        }
                    }
                    
                }
            }
            
            tweetTime?.text = dateFormatter.stringFromDate(tweet.created)
        }
    }

}
