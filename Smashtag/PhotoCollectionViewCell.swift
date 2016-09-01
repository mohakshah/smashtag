//
//  PhotoCollectionViewCell.swift
//  Smashtag
//
//  Created by Mohak Shah on 27/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    // model
    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    // simple wrapper around the imageView's image
    private var imageDisplayed: UIImage? {
        set {
            imageView?.image = newValue
            resizeImageView()
        }
        
        get {
            return imageView?.image
        }
    }
    
    private func resizeImageView() {
        if let image = imageDisplayed {
            let aspectRatio = image.size.width / image.size.height
            if aspectRatio > 1.0 {
                let newSize = CGSize(width: frame.width, height: frame.height / aspectRatio)
                imageView.frame = CGRect(origin: CGPoint(x: 0, y: (frame.height - newSize.height) / 2), size: newSize)
            } else {
                let newSize = CGSize(width: frame.width * aspectRatio, height: frame.height)
                imageView.frame = CGRect(origin: CGPoint(x: (frame.width - newSize.width) / 2, y: 0), size: newSize)
            }
        }
        
    }
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private func updateUI() {
        loadingIndicator.startAnimating()
        imageDisplayed = nil
        
        // download the image on a different thread
        if let url = imageURL {
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
                    if weakSelf?.imageURL == url {
                        weakSelf?.loadingIndicator.stopAnimating()
                        weakSelf?.imageDisplayed = image
                    }
                }
            }
        }
    }
}
