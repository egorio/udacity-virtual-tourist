//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/24/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import UIKit

class ImageCache {

    static private let shared: NSCache = {
        let cache = NSCache()
        cache.name = "images"
        cache.countLimit = 200 // Max number of images in memory.
        cache.totalCostLimit = (cache.countLimit / 2) * 1024 * 1024 // Max Mb can be used (500 Kb per photo).
        return cache
    }()

    static func get(key: String) -> UIImage? {
        return shared.objectForKey(key) as? UIImage
    }

    static func set(image: UIImage, forKey: String) {
        shared.setObject(image, forKey: forKey, cost: (UIImageJPEGRepresentation(image, 0)?.length) ?? 0)
    }
}