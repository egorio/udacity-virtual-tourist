//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/18/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/*
 * Photo model represents photos from Flickr
 */
class Photo: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var url: String
    @NSManaged var pin: Pin

    // Store current downloading file task
    var task: NSURLSessionTask? = nil

    // File path... we also use path as cache key :)
    lazy var filePath: String = {
        return NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            .URLByAppendingPathComponent("image-\(self.id).jpg").path!
    }()

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(id: String, url: String, pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        self.id = id
        self.url = url
        self.pin = pin
    }

    /*
     * Make Photo object from Flickr search result photo object
     */
    init(flickrDictionary: [String: AnyObject], pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        self.id = flickrDictionary["id"] as! String
        self.url = flickrDictionary["url_m"] as! String
        self.pin = pin
    }

    /*
     * Run backgroud task to download image for url
     */
    func startLoadingImage(handler: (image : UIImage?, error: String?) -> Void) {
        // Check in memory
        if let image = MemoryCache.get(filePath) {
            print("Photo loaded from memory cache")
            return handler(image: image, error: nil)
        }

        // Check in file sistem
        if let image = FileCache.get(filePath) {
            print("Photo loaded from file cache")
            return handler(image: image, error: nil)
        }

        cancelLoadingImage()
        task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: url)!)) { data, response, downloadError in
            dispatch_async(dispatch_get_main_queue(), {
                guard downloadError == nil else {
                    print("Photo loading canceled")
                    return handler(image: nil, error: "Photo loadnig canceled")
                }

                guard let data = data, let image = UIImage(data: data) else {
                    print("Photo not loaded")
                    return handler(image: nil, error: "Photo not loaded")
                }

                MemoryCache.set(image, forKey: self.filePath)
                FileCache.set(image, forPath: self.filePath)

                print("Photo loaded from internet")
                return handler(image: image, error: nil)
            })
        }
        task!.resume()
    }

    /*
     * Cancel downloading process if it's running
     */
    func cancelLoadingImage() {
        task?.cancel()
    }

    /*
     * Remove image from local storage when photo deleted
     */
    override func prepareForDeletion() {
        super.prepareForDeletion()

        MemoryCache.remove(self.filePath)
        FileCache.remove(self.filePath)
    }
}