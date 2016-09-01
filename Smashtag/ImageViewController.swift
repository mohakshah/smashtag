//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 23/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isRootOfNavigationVC {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(self.popToHome))
        }
        
        scrollView.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        // recalculate the minimum zoom scale when the scrollView's geometry changes
        setMinimumZoomScale()
        setCurrentZoomScale()
    }
    

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            if scrollView != nil {
                scrollView.contentSize = imageView.frame.size
                scrollView.delegate = self
                scrollView.maximumZoomScale = 1.0
            }
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private let imageView = UIImageView()
    
    // a simple wrapper around the imageView's image
    private var image: UIImage? {
        set {
            imageView.image = newValue
            
            loadingIndicator?.stopAnimating()
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            setMinimumZoomScale()
            setCurrentZoomScale()
        }
        
        get {
            return imageView.image
        }
    }
    
    // the function decides what the minimumZoom Scale of the scrollView should be
    private func setMinimumZoomScale() {
        if scrollView != nil && image != nil {
            let widthRatio = scrollView.bounds.width / image!.size.width
            let heightRatio = scrollView.bounds.height / image!.size.height
            
            var minimumZoomScale: CGFloat
            if widthRatio < 1.0 {
                if heightRatio < 1.0 {
                    // set the minimum zoom scale to the smaller of the two
                    minimumZoomScale = (widthRatio < heightRatio) ? widthRatio : heightRatio
                } else {
                    minimumZoomScale = widthRatio
                }
            } else if heightRatio < 1.0 {
                minimumZoomScale = heightRatio
            } else {
                minimumZoomScale = 1.0
            }
            
            // if the new minimum zoom scale is greater than the current zoom scale,
            // change the scroll view's zoom to the new minimum one
            if (minimumZoomScale > scrollView.zoomScale) {
                scrollView.zoomScale = minimumZoomScale
            }
            
            scrollView.minimumZoomScale = minimumZoomScale
        }
    }
    
    
    // sets the zoom scale of the scrollView in such a way that
    // maximum portion of the image is shown without any whitespace
    private func setCurrentZoomScale() {
        if scrollView != nil && image != nil {
            let widthRatio = scrollView.bounds.width / image!.size.width
            let heightRatio = scrollView.bounds.height / image!.size.height
            
            if widthRatio < 1.0 && heightRatio < 1.0 {
                scrollView.zoomScale = (widthRatio > heightRatio) ? widthRatio : heightRatio
            }
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            loadImage()
        }
    }
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            if image == nil {
                loadingIndicator.startAnimating()
            }
        }
    }

    // fetches the image from imageURL asynchronously on the USER_INITIATED  queue and sets
    // the image on the main queue
    private func loadImage() {
        loadingIndicator?.startAnimating()
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
                        weakSelf?.image = image
                    }
                }
            }
        }
    }
}