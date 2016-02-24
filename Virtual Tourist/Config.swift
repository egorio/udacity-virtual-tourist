//
//  Config.swift
//  MyFavoriteMovies
//
//  Created by Jason on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import MapKit

class Config: NSObject {

    // Available application config params
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var latitudeDelta: CLLocationDegrees = 0
    var longitudeDelta: CLLocationDegrees = 0

    // Additional params
    var mapRegion: MKCoordinateRegion? {
        get {
            guard longitude != 0 && latitude != 0 && latitudeDelta != 0 && longitudeDelta != 0 else {
                return nil
            }

            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        }
        set {
            latitude = newValue?.center.latitude ?? 0
            longitude = newValue?.center.longitude ?? 0
            latitudeDelta = newValue?.span.latitudeDelta ?? 0
            longitudeDelta = newValue?.span.longitudeDelta ?? 0
        }
    }

    // Singleton instance of Config
    static let shared = Config()

    private override init() {
        super.init()
        load()
    }

    /*
     * Return path to config file
     */
    private lazy var fileUrl: NSURL = {
        return NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            .URLByAppendingPathComponent("config")
    }()

    /*
     * Preload config values from the file
     */
    func load() {
        guard NSFileManager.defaultManager().fileExistsAtPath(fileUrl.path!) else {
            return
        }

        let config = (NSKeyedUnarchiver.unarchiveObjectWithFile(fileUrl.path!) as! [String: AnyObject])

        self.setValuesForKeysWithDictionary(config)
    }

    /*
     * Save config to the file
     */
    func save() {
        let keys = ["latitude", "longitude", "latitudeDelta", "longitudeDelta"]

        NSKeyedArchiver.archiveRootObject(self.dictionaryWithValuesForKeys(keys), toFile: fileUrl.path!)
    }
}
