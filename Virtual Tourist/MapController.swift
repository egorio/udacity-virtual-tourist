//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/17/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapController: ViewController, MKMapViewDelegate {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem()

        mapView.delegate = self
        mapView.addAnnotations(fetchAllPins())
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "createPin:"))

        // Restore previous state of the map
        if let region = Config.shared.mapRegion {
            mapView.setRegion(region, animated: true)
        }
    }

    /*
     * Change controler state to editing and back
     */
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: false)

        // Show the hint when controller in "editing" mode
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame.origin.y += self.hintLabel.frame.height * (editing ? -1 : 1)
        })
    }

    /*
     * Load all pins from the core data
     */
    func fetchAllPins() -> [Pin] {
        do {
            print("Pins are loaded")
            return try context.executeFetchRequest(NSFetchRequest(entityName: "Pin")) as! [Pin]
        } catch {
            print("Oops... we could not load pins")
            return []
        }
    }

    /*
     * Add annotation (pin) to the map by long pressing
     */
    func createPin(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            let point = sender.locationInView(mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)

            let pin = Pin(latitude: coordinate.latitude as Double, longitude: coordinate.longitude as Double, context: context)

            // As soon as new pin is created - try to find photos for it in background
            pin.flickr.loadNewPhotos(context, handler: { _ in self.context.saveQuietly() })

            mapView.addAnnotation(pin)

            context.saveQuietly()

            print("Pin created")
        }
    }

    /*
     * View pin photo collection
     */
    func viewPin(pin: Pin) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("CollectionController") as! CollectionController

        controller.pin = pin

        navigationController!.pushViewController(controller, animated: true)

        print("Go to Pin view")
    }

    /*
     * Delete pin from the map and core data
     */
    func deletePin(pin: Pin) {
        mapView.removeAnnotation(pin)
        context.deleteObject(pin)
        context.saveQuietly()

        print("Pin deleted")
    }

    /*
     * Save map state (position) to the app config file
     */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Config.shared.mapRegion = mapView.region
        Config.shared.save()

        print("Map position saved")
    }

    /*
     * Configure the annotation (pin) view to be draggable and animated :)
     */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        let pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        pinView.animatesDrop = true
        pinView.draggable = true

        // Func didChangeDragState will call only after pin been selected. Let's make all pins selected by default.
        pinView.selected = true

        return pinView
    }

    /*
     * Update pin coordinates when it is moved
     */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if oldState == .Ending {
            let pin = view.annotation as! Pin

            // When pin was moved it's time to replace photos with new ones
            pin.deletePhotos(context, handler: { _ in self.context.saveQuietly() })
            pin.flickr.loadNewPhotos(context, handler: { _ in self.context.saveQuietly() })

            print("Pin moved")
        }
    }

    /*
     * Show or delete pin on tap
     */
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let pin = view.annotation as! Pin

        // Remove current pin from selected list to allow it be selected again
        mapView.deselectAnnotation(pin, animated: false)

        editing ? deletePin(pin) : viewPin(pin)
    }

    /*
     * Deselect pin after it was selected
     * We have to keep "selected = true" to allow pin be draggble without additional tap (selection)
     */
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        view.selected = true
    }
}
