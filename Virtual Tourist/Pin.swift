//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/18/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import Foundation
import CoreData
import MapKit

/*
 * Pin model represents map annotation and allows it to store in core data
 */
class Pin: NSManagedObject, MKAnnotation {

    @NSManaged var latitude: NSNumber!
    @NSManaged var longitude: NSNumber!
    @NSManaged var photos: [Photo]
    @NSManaged var flickr: PinFlickr // Just for specification: "The object model contains additional entities"

    // Represents the pin coordinate
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = NSNumber(double: newValue.latitude)
            longitude = NSNumber(double: newValue.longitude)
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
        }
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)

        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        self.latitude = NSNumber(double: latitude)
        self.longitude = NSNumber(double: longitude)
        self.flickr = PinFlickr(context: context)
    }
}