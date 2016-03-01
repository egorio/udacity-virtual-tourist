# Virtual Tourist

The Virtual Tourist is result of **iOS Persistence and Core Data** lesson of **Udacity's iOS Developer Nanodegree** course.

The app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour. 
Users will then be able to download pictures for the location and persist boththe pictures, and the association of 
the pictures with the pin coordinates. Users will also be able to move pins to download new pictures and remove pins if
they need them anymore.

![MapController](https://raw.githubusercontent.com/egorio/udacity-virtual-tourist/master/Screenshots/map-controller.png)
![CollectionController](https://raw.githubusercontent.com/egorio/udacity-virtual-tourist/master/Screenshots/collection-controller.png)

## Implementation

The app has two view controller scenes:

- **MapController** - shows the map and allows user to drop pins around the world. Users can drag pin to a new location after
  dropping them. As soon as a pin is dropped photo data for the pin location is fetched from Flickr. The actual photo
  downloads occur in the CollectionController.

- **CollectionController** - allow users to download photos and edit an album for a location. Users can create new
  collections and delete photos from existing albums.

Application uses CoreData to store Pins (`NSManagedObjectContext.executeFetchRequest`) and Photos 
(`NSFetchedResultsController`) objects. All API calls run in background (`NSURLSession.dataTaskWithRequest`).
Preloaded files saved in memory cache (`NSCache`) and file system (`NSFileManager`) and removed as soon as Photo object 
removed from CoreData.



## Requirements

 - Xcode 7.2
 - Swift 2.0

## License

Copyright (c) 2016 Egor Verbitskiy

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
