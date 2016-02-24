//
//  CollectionController.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/18/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    var pin: Pin? = nil

    // We will use it in NSFetchedResultsControllerDelegate
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: "goBackToMap")

        mapView.addAnnotation(pin!)
        mapView.setRegion(MKCoordinateRegion(center: pin!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        mapView.userInteractionEnabled = false

        collectionView.delegate = self
        collectionView.dataSource = self

        setupCollectionFlowLayout()

        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()

            print("Photos loaded from core data")
        } catch { }
    }

    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Photo")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!);

        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
    }()

    /*
     * Change controler state to editing and back
     */
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: false)

        // Show the hint when controller in "editing" mode
        UIView.animateWithDuration(0.3, animations: {
            self.view.constraints.filter({ $0.identifier == "HintLabelToBottom"}).first!.constant = editing ? 0 : -self.hintLabel.frame.height
            self.newCollectionButton.enabled = !editing
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func loadPhotos(sender: AnyObject? = nil) {
        guard newCollectionButton.enabled == true else {
            return
        }

        // Remove current photos
        let photos = fetchedResultsController.fetchedObjects as? [Photo] ?? []
        for photo in photos {
            context.deleteObject(photo)
        }

        context.saveQuietly()

        newCollectionButton.enabled = false

        // Load new photos from Flickr
        FlickrClient.shared.getPhotosByLocation(pin!.latitude as Double, longitude: pin!.longitude as Double) { (photos, error) -> Void in
            guard error == nil else {
                return
            }

            for photo in photos! where photo["url_m"] != nil {
                _ = Photo(flickrDictionary: photo, pin: self.pin!, context: self.context)
            }

            self.context.saveQuietly()

            dispatch_async(dispatch_get_main_queue(), {
                self.newCollectionButton.enabled = true
            })

            print("Photos loaded from internet")
        }
    }

    /*
     * Go to MapController
     */
    func goBackToMap() {
        navigationController?.popViewControllerAnimated(true)

        print("Go to Map view")
    }

    /*
     * Number of sections been fetched
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    /*
     * Number of photos been fetched
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    /*
     * Return one collection cell prepared to display
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell

        cell.photo = photo

        return cell
    }

    /*
     * Delete cell
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            context.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
            context.saveQuietly()

            print("Photo deleted")
        }
        else {
            // Preview photo
        }
    }

    /*
     * Recaltulate cell sizes on iphone rotating
     */
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setupCollectionFlowLayout()
    }

    /*
     * Configure cells size and spacing between them
     */
    func setupCollectionFlowLayout() {
        let items: CGFloat = view.frame.size.width > view.frame.size.height ? 5.0 : 3.0
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - ((items + 1) * space)) / items

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 8.0 - items
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSizeMake(dimension, dimension)

        collectionView.collectionViewLayout = layout

        print("Cells configured")
    }
}

extension CollectionController: NSFetchedResultsControllerDelegate {

    /*
     * Prepare to interting or deleting cells
     */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = []
        deletedIndexPaths = []
    }

    /*
     * Handle inserting and deleting photo from core data storage
     * We have to save indexPaths for collection batch update
     */
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        default: ()
        }
    }

    /*
     * Update collection view
     */
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }

            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }

            print("Collection updated")
            }, completion: nil)
    }
}
