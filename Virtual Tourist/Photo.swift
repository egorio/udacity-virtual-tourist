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

        print(flickrDictionary)

        self.id = flickrDictionary["id"] as! String
        self.url = flickrDictionary["url_m"] as! String
        self.pin = pin
    }
}