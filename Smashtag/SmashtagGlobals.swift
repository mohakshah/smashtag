//
//  SmashtagConstants.swift
//  Smashtag
//
//  Created by Mohak Shah on 26/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation
import UIKit



let standardUserDefaults = NSUserDefaults.standardUserDefaults()

struct RecentQueries {
    static let UserDefaultsKeys = "RecentQueries"
    static let MaxQueries = 100
    
    static var list: [String]? {
        get {
            if let queries = standardUserDefaults.objectForKey(UserDefaultsKeys) as? [String] {
                return queries
            }
            
            return nil
        }
        set {
            if newValue == nil {
                standardUserDefaults.setObject(nil, forKey: UserDefaultsKeys)
                return
            }
            
            
            var queries = newValue!
            
            if queries.count > MaxQueries {
                queries.removeLast(queries.count - MaxQueries)
            }
            
            
            standardUserDefaults.setObject(queries, forKey: UserDefaultsKeys)
        }
    }
}

extension UIViewController {
    var isRootOfNavigationVC: Bool {
        if let navVC = navigationController {
            return navVC.visibleViewController == navVC.viewControllers[0]
        } else {
            return false
        }
    }
    
    var mainViewController: UIViewController {
        if let navVC = self as? UINavigationController {
            return navVC.visibleViewController ?? self
        }
        
        return self
    }
    
    func popToHome() {
        if let navVC = navigationController {
            if !isRootOfNavigationVC {
                navVC.popToRootViewControllerAnimated(true)
            }
        }
    }
}

let imageCache = NSCache()