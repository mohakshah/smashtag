//
//  TweetDetailViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 22/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import Twitter

class TweetDetailViewController: UITableViewController
{
    // model
    var tweet: Tweet? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var sections = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = tweet?.user.screenName
        
        // only include sections which have 1 or more cells
        if tweet?.media.count > 0 {
            sections.append("Images")
        }
        
        
        if tweet?.hashtags.count > 0 {
            sections.append("Hashtags")
        }
        
        
        if tweet?.userMentions.count > 0 {
            sections.append("Mentions")
        }
        
        if tweet?.urls.count > 0 {
            sections.append("URLs")
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: UITableViewCell

        // prepare the cell
        if tweet != nil {
            if sections[indexPath.section] == "Images" {
                cell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: indexPath)
                if let imageCell = cell as? TweetImageTableViewCell {
                        imageCell.mediaItem = tweet!.media[indexPath.row]
                }
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath)
                switch sections[indexPath.section] {
                case "Hashtags":
                    cell.textLabel?.text = tweet!.hashtags[indexPath.row].keyword
                    
                case  "Mentions":
                    cell.textLabel?.text = tweet!.userMentions[indexPath.row].keyword
                    
                case "URLs":
                    cell.textLabel?.text = tweet!.urls[indexPath.row].keyword
                    
                default:
                    break
                }
            }
        } else {
            // since the model is not set, return an empty text cell
            cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath)
            cell.textLabel?.text = nil
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sections[section]
    }
    
    // height of image cells will be as per the image's aspect ratio
    // height of the rest of the cells will be set to UITableViewAutomaticDimension
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if sections[indexPath.section] == "Images" {
            if let ar = tweet?.media[indexPath.row].aspectRatio {
                return tableView.bounds.width / CGFloat(ar)
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    private func numberOfRowsInSection(section: Int) -> Int {
        if let tweet = self.tweet {
            switch sections[section] {
            case "Images":
                return tweet.media.count
                
            case "Hashtags":
                return tweet.hashtags.count
                
            case "Mentions":
                return tweet.userMentions.count
                
            case "URLs":
                return tweet.urls.count
                
            default:
                return 0
            }
        }
        
        return 0
    }
    
    // segues to relevant views when a row is tapped
    // images segue to showImage
    // hashtags and mentions segue to "ReSearch"
    // URLs open the link in Safari
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch sections[indexPath.section] {
        case "Images" where tweet != nil:
            performSegueWithIdentifier("showImage", sender: tweet!.media[indexPath.row].url)

        case "Hashtags" where tweet != nil:
            performSegueWithIdentifier("ReSearch", sender: tweet?.hashtags[indexPath.row].keyword)
            
        case "Mentions" where tweet != nil:
            performSegueWithIdentifier("ReSearch", sender: tweet?.userMentions[indexPath.row].keyword)
            
        case "URLs" where tweet != nil:
            if let urlString = tweet?.urls[indexPath.row].keyword {
                if let url = NSURL(string: urlString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let searchString = sender as? String where segue.identifier == "ReSearch" {
            if let tweetTableVC = segue.destinationViewController as? TweetTableViewController {
                tweetTableVC.searchString = searchString
            }
        } else if let imageURL = sender as? NSURL where segue.identifier == "showImage" {
            if let imageView = segue.destinationViewController as? ImageViewController {
                imageView.imageURL = imageURL
            }
        }
    }
}
