//
//  TwettImageTableViewCell.swift
//  Smashtag
//
//  Created by Mohak Shah on 23/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import Twitter

class TweetImageTableViewCell: UITableViewCell {
    // model
    var mediaItem: MediaItem? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViewOfCell: UIImageView!
    
    // simple wrapper around the imageView's image
    private var imageDisplayed: UIImage? {
        set {
            imageViewOfCell.image = newValue
        }
        
        get {
            return imageViewOfCell?.image
        }
    }
    
    private func updateUI() {
        loadingIndicator.startAnimating()
        if let url = mediaItem?.url {
            
            // download the image on a different thread
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
                // fetch the image
                if let imageData = NSData(contentsOfURL: url) {
                    dispatch_async(dispatch_get_main_queue()) {
                        // make sure the cell hasn't been re-purposed
                        if weakSelf?.mediaItem?.url == url {
                            weakSelf?.loadingIndicator.stopAnimating()
                            weakSelf?.imageDisplayed = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}
