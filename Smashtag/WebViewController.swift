//
//  WebViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 27/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // helpful when debuggin
        if url == nil {
            url = NSURL(string: "https://www.wikipedia.org")
        }
        
        // set up the loadingIndicator
        loadingIndicator.color = UIColor.grayColor()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        // set up a WKWebView
        webView = WKWebView(frame: containerView.frame)
        containerView.addSubview(webView!)
        
        // add navigation buttons to toolbarItems
        let backButton = UIBarButtonItem(title: "◀︎", style: .Plain, target: webView, action: #selector(webView!.goBack))
        let forwardButton = UIBarButtonItem(title: "▶︎", style: .Plain, target: webView, action: #selector(webView!.goForward))
        
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(webView!.reload))
        stopButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(stopLoading))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let indicator = UIBarButtonItem(customView: loadingIndicator)
        
        toolbarItems = [backButton, forwardButton, refreshButton!, flexibleSpace, indicator]
        if let navVC = navigationController {
            navVC.toolbarHidden = false
            navVC.hidesBarsOnSwipe = true
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(popToLastView))
    }
    
    override func viewDidLayoutSubviews() {
        // the webView's frame doesn't change automatically
        webView?.frame = containerView.frame
    }
    
    @objc private func popToLastView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func stopLoading() {
        webView?.stopLoading()
        loadingIndicator.stopAnimating()
        title = webView?.title
        
        // replace stopButton with refreshButton
        if toolbarItems != nil && refreshButton != nil && stopButton != nil {
            if let stopButtonIndex = toolbarItems!.indexOf(stopButton!) {
                toolbarItems![stopButtonIndex] = refreshButton!
            }
        }
        
    }
    
    private let loadingIndicator = UIActivityIndicatorView()
    
    private var refreshButton: UIBarButtonItem?
    private var stopButton: UIBarButtonItem?
    
    
    private var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
            if url != nil {
                webView?.loadRequest(NSURLRequest(URL: url!))
            }
        }
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
        
        // replace refresh button with stop button
        if toolbarItems != nil && refreshButton != nil && stopButton != nil {
            if let refreshButtonIndex = toolbarItems!.indexOf(refreshButton!) {
                toolbarItems![refreshButtonIndex] = stopButton!
            }
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        title = webView.title
        
        // replace stopButton with refreshButton
        if toolbarItems != nil && refreshButton != nil && stopButton != nil {
            if let stopButtonIndex = toolbarItems!.indexOf(stopButton!) {
                toolbarItems![stopButtonIndex] = refreshButton!
            }
        }
    }
        
    @IBOutlet var containerView: UIView!
    // model
    var url: NSURL? {
        didSet {
            if url != nil {
                webView?.loadRequest(NSURLRequest(URL: url!))
            }
        }
    }

}
