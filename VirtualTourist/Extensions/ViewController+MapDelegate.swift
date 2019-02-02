//
//  ViewController+MapDelegate.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 24/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension ViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // save the map center and zoom level as soon as the map region has changed
        UserDefaults.standard.set(mapView.region.center.longitude, forKey:"longitude")
        UserDefaults.standard.set(mapView.region.center.latitude, forKey:"latitude")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey:"longitudeDelta")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey:"latitudeDelta")
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        
        selectedPin = getPin(latitude: String(annotation.coordinate.latitude), longtude: String(annotation.coordinate.longitude))

        performSegue(withIdentifier: "showPinAlbum", sender: nil)
    }
    
    // MARK: Helper method to get selected pin
    private func getPin(latitude: String, longtude: String) -> Pin? {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "longtude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "latitude == %@ AND longtude == %@", latitude, longtude)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        var pin: Pin?
        do {
            try fetchedResultsController.performFetch()
            guard let locations = fetchedResultsController.fetchedObjects else {
                return nil
            }
            pin = locations.first
        } catch {
            print("\(#function) error:\(error)")
            showAlert(title: "Eroor", message: "Error while fetching location: \(error)")
        }
        
        return pin
    }
    
}
