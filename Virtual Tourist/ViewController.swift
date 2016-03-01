//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Egorio on 2/9/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // Current core data context
    lazy var context: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
}
