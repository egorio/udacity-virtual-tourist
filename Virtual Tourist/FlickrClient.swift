//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/22/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import Foundation

/*
 * Flickr API client
 */
class FlickrClient: ApiClient {

    let apiUrl = "https://api.flickr.com/services/rest/"
    let apiKey = "8c478e5a68b4cd1b92f53f31d039d831"

    // Singleton instance of FlickrClient
    static let shared = FlickrClient()

    /*
     * Returns photos
     */
    func getPhotosByLocation(latitude: Double, longitude: Double, handler: (photos: [[String : AnyObject]]?, error: String?) -> Void) {

        let params = [
            "method": "flickr.photos.search",
            "api_key": apiKey,
            "bbox": createBoundingBoxString(latitude, longitude: longitude),
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1",
            "per_page": "30",
        ]

        let request = prepareRequest("\(apiUrl)", params: params)

        processResuest(request) { (result, error) -> Void in
            guard error == nil else {
                handler(photos: nil, error: error)
                return
            }

            guard let photoData = result!["photos"] as? [String : AnyObject] else {
                print("Can't find [photos] in response")
                handler(photos: nil, error: "Connection error")
                return
            }

            guard let results = photoData["photo"] as? [[String : AnyObject]] else {
                print("Can't find [photos][photo] in response")
                handler(photos: nil, error: "Connection error")
                return
            }

            handler(photos: results, error: nil)
        }
    }

    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {

        let BOUNDING_BOX_HALF_WIDTH = 1.0
        let BOUNDING_BOX_HALF_HEIGHT = 1.0
        let LAT_MIN = -90.0
        let LAT_MAX = 90.0
        let LON_MIN = -180.0
        let LON_MAX = 180.0

        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)

        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}
