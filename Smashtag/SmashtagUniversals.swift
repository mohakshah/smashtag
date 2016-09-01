//
//  SmashtagConstants.swift
//  Smashtag
//
//  Created by Mohak Shah on 26/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation
import UIKit

struct UserDefaultsKeys {
    static let recentQueries = "RecentQueries"
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