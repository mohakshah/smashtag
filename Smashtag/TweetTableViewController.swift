//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 22/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    // model
    var tweets = [Array<Twitter.Tweet>] () {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchString: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchString
            addSearchStringToRecentSearches()
        }
    }
    
    let standardUserDefaults = NSUserDefaults.standardUserDefaults()
    
    /*
     * searches the standard user defaults for the recent queries and updates the list to include the current
     * query. Also removes any duplicates and trims the list down to the 100 most recent searches
     */
    private func addSearchStringToRecentSearches() {
        if let searchString = self.searchString {
            if var queries  = standardUserDefaults.objectForKey(UserDefaultsKeys.recentQueries) as? Array<String> {
                
                // remove duplicates
                var i = 0
                while i < queries.count {
                    if queries[i].caseInsensitiveCompare(searchString) == .OrderedSame {
                        queries.removeAtIndex(i)
                        i -= 1
                    }
                    i += 1
                }
                
                // add the new query
                queries.insert(searchString, atIndex: 0)
                
                // trim to size of <= 100
                if queries.count > 100 {
                    queries.removeLast(queries.count - 100)
                }
                
                // save to user defaults
                standardUserDefaults.setObject(queries, forKey: UserDefaultsKeys.recentQueries)
            } else {
                // since there are no existing queries in the history, just add the current one
                // as an array containing 1 element
                standardUserDefaults.setObject([searchString], forKey: UserDefaultsKeys.recentQueries)
            }
        }
    }
    
    // returns a Twitter.Request object constructed from the searchString
    private var twitterRequest: Twitter.Request? {
        if let query = searchString where !query.isEmpty {
            return Request(search: query + " -filter:retweets", count: 100)
        }
        
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    // asynchronously searches for tweets
    private func searchForTweets() {
        if let request = twitterRequest {
            lastTwitterRequest = request
            
            request.fetchTweets { [weak weakSelf = self] (newTweets) in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        weakSelf?.tweets.insert(newTweets, atIndex: 0)
                    }
                }
            }
        }
    }
    
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchString
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // only consider if the user has entered a non-empty string
        if let userInput = textField.text {
            if userInput.isEmpty {
                return false
            }
            
            textField.resignFirstResponder()
            searchString = userInput
            return true
        }
        
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if searchString == nil {
            searchString = "#500px"
        }
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? TweetTableViewCell {
            if let tweetDetailVC = segue.destinationViewController as? TweetDetailViewController {
                // set the model of the detail vc
                tweetDetailVC.tweet = cell.tweet
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    let reusableCellIdentifier = "TweetCell"

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableCellIdentifier, forIndexPath: indexPath)
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
}
