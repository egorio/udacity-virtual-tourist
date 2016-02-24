//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/19/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var task: NSURLSessionTask? = nil

    var photo: Photo? = nil {
        didSet {
            // Cancel prewious task to avoid loading wrong image
            task?.cancel()
            loading = true

            if let image = ImageCache.get(photo!.url) {
                loading = false
                imageView.image = image

                print("Photo loaded from cache")
            } else {

                task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: photo!.url)!)) { data, response, downloadError in
                    dispatch_async(dispatch_get_main_queue()) {
                        guard downloadError == nil else {
                            print("Photo loading canceled")
                            return
                        }

                        guard let data = data, let image = UIImage(data: data) else {
                            // We can set some "empty.jpg" to
                            return
                        }

                        self.loading = false
                        self.imageView.image = image

                        ImageCache.set(image, forKey: self.photo!.url)

                        print("Photo loaded from internet")
                    }
                }
                task!.resume()
            }
        }
    }

    // Allow to switch cell to "loading" state
    var loading: Bool {
        set {
            if newValue {
                imageView.image = nil
                activityIndicator.startAnimating()
                activityIndicator.hidden = false
            }
            else {
                activityIndicator.stopAnimating()
                activityIndicator.hidden = true
            }
        }
        get {
            return !activityIndicator.hidden
        }
    }
}