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
        // download the image on a different thread
        if let url = mediaItem?.url {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
                // check the image cache, else fetch it
                var image: UIImage
                if let cachedImage = imageCache.objectForKey(url) as? UIImage {
                    image = cachedImage
                } else if let imageData = NSData(contentsOfURL: url) {
                    if let downloadedImage = UIImage(data: imageData) {
                        image = downloadedImage
                        imageCache.setObject(image, forKey: url, cost: imageData.length)
                    } else {
                        return
                    }
                } else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    if weakSelf?.mediaItem?.url == url {
                        weakSelf?.loadingIndicator.stopAnimating()
                        weakSelf?.imageDisplayed = image
                    }
                }
            }
        }
    }
}
