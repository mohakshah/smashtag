//
//  PhotoCollectionViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 27/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import Twitter

private let reuseIdentifier = "PhotoCell"

class PhotoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // model
    var mediaItems: [MediaItem]? {
        didSet {
            collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isRootOfNavigationVC {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(self.popToHome))
        }
        
        collectionView?.backgroundColor = UIColor.whiteColor()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    private var defaultCellDimension = CGFloat(100.0) {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    @IBOutlet var myCollectionView: UICollectionView! {
        didSet {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleThumbnails(_:)))
            myCollectionView?.addGestureRecognizer(pinchRecognizer)
        }
    }
    
    
    func scaleThumbnails(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Changed, .Ended:
//            print(sender.scale)
            defaultCellDimension *= sender.scale
            sender.scale = 1.0
        default:
            break
        }
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return mediaItems!.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        if let pcvc = cell as? PhotoCollectionViewCell {
            pcvc.imageURL = mediaItems![indexPath.row].url
        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowFullImage", sender: mediaItems![indexPath.row].url)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: defaultCellDimension, height: defaultCellDimension)
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let imageVC = segue.destinationViewController as? ImageViewController {
            if let url = sender as? NSURL {
                imageVC.imageURL = url
            }
        }
    }

}
