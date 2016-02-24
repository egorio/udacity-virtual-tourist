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

    /*
     * Show alert with title "Error", message and one button to dismiss the alert
     */
    func showErrorAlert(message: String, dismissButtonTitle: String = "OK") {
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)

        controller.addAction(UIAlertAction(title: dismissButtonTitle, style: .Default) { (action: UIAlertAction!) in
            controller.dismissViewControllerAnimated(true, completion: nil)
        })

        self.presentViewController(controller, animated: true, completion: nil)
    }

    /*
     * Show alert with message and two buttons
     */
    func showConfirmationAlert(message: String, dismissButtonTitle: String = "Cancel", actionButtonTitle: String = "OK", handler: ((UIAlertAction!) -> Void)) {
        let controller = UIAlertController(title: "", message: message, preferredStyle: .Alert)

        controller.addAction(UIAlertAction(title: dismissButtonTitle, style: .Default) { (action: UIAlertAction!) in
            controller.dismissViewControllerAnimated(true, completion: nil)
        })

        controller.addAction(UIAlertAction(title: actionButtonTitle, style: .Default, handler: handler))

        self.presentViewController(controller, animated: true, completion: nil)
    }

    /*
     * Present alert with specific storyboard identifier
     */
    func presentViewControllerWithIdentifier(identifier: String, animated: Bool = true, completion: (() -> Void)? = nil) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier(identifier)
        presentViewController(controller, animated: animated, completion: completion)
    }
}
