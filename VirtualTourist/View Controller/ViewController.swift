//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 23/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var selectedPin: Pin?
    
    fileprivate func setUpFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "longtude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Couldn't fetch data \(error.localizedDescription)")
        }
        loadMapPins()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self

        let span = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey:"latitudeDelta"), longitudeDelta: UserDefaults.standard.double(forKey:"longitudeDelta"))
        let center = CLLocationCoordinate2DMake(
            UserDefaults.standard.double(forKey:"latitude"),
            UserDefaults.standard.double(forKey:"longitude"))
        let region = MKCoordinateRegion(center: center, span: span)
         mapView.setRegion(region, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        selectedPin = nil
    }
    
    func loadMapPins(){
        
        guard let locations = fetchedResultsController.fetchedObjects else {
            return
        }
        
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longtude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // add annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let pinAnnotation = MKPointAnnotation()
        
        if sender.state == .began {
            pinAnnotation.coordinate = locationCoordinate
            mapView.addAnnotation(pinAnnotation)
        } else if sender.state == .changed {
            pinAnnotation.coordinate = locationCoordinate
        } else if sender.state == .ended {
            addPinInfo(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        }
    }
    
    func addPinInfo(latitude: Double, longitude: Double){
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longtude = longitude
        try? dataController.viewContext.save()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PinAlbumViewController {
            vc.pin = selectedPin
            vc.dataController = dataController
        }
    }

}


