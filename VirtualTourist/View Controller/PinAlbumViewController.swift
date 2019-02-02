//
//  PinAlbumViewController.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 24/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import Kingfisher

class PinAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pin: Pin?
    var photos: PhotosInfo?
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinPhotosCollection: UICollectionView!
    @IBOutlet weak var pinPhotoFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var statusLabel: UILabel!
    
    fileprivate func setUpFetchedResultsController(pin: Pin) {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "pin", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Couldn't fetch data \(error.localizedDescription)")
        }
    }
    
    func setupColletion(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        pinPhotoFlowLayout.minimumInteritemSpacing = space
        pinPhotoFlowLayout.minimumLineSpacing = space
        pinPhotoFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        guard let pin = pin else {
            return
        }
        showPinLocation()
        setUpFetchedResultsController(pin: pin)
        
        self.pinPhotosCollection.delegate = self
        self.pinPhotosCollection.dataSource = self
        
        if let photos = pin.photos, photos.count == 0 {
            //pin has no photos
            print(photos.count)
            loadPinPhotos(latitude: pin.latitude, longitude: pin.longtude)
        }
        
        pinPhotosCollection.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showPinLocation(){
        guard let latitude = pin?.latitude, let longtude = pin?.longtude else {
            showAlert(title: "Error", message: "No Location Information Found")
            return
        }
        
        let pinAnnotation = MKPointAnnotation()
        
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longtude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        pinAnnotation.coordinate = coordinate
        mapView.addAnnotation(pinAnnotation)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    func loadPinPhotos(latitude: Double, longitude:Double){
        API.searchPhootoForPinLocatio(latitude: latitude, longitude: longitude) { (result, err) in
            if let result = result {
                let totalPhotos = result.photos.photo.count
                print("\(#function) Downloading \(totalPhotos) photos.")
                DispatchQueue.main.async {
                    self.addPinPhotos(photos: result, forPin: self.pin!)
                }
                    if totalPhotos == 0 {
                        self.statusLabel.text = "No photos found for this location."
                }
                } else if let err = err {
                    self.showAlert(title: "Error", message: "\(err)")
            }
        }
    }
    
    func addPinPhotos(photos: PhotosInfo, forPin:Pin) {
        for photoInfo in photos.photos.photo {
            let photo = Photo(context: dataController.viewContext)
            photo.imageUrl = photoInfo.url
            photo.title = photoInfo.title
            photo.pin = pin
        }
        try? dataController.viewContext.save()
    }
    
    func loadImage(url:String) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
        }
        
        task.resume()
        
    }
    
    @IBAction func loadNewCollection(_ sender: UIButton) {
        guard let pin = pin else {
            return
        }
        for photoToDelete in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photoToDelete)
        }
        try? dataController.viewContext.save()
        loadPinPhotos(latitude: pin.latitude, longitude: pin.longtude)
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
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pin = pin else {
            return 0
        }
        
        if let photos = pin.photos {
            return photos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        if let imageData = fetchedResultsController.object(at: indexPath).imageData {
            cell.imageView.image = UIImage(data: imageData)
        } else {
        let url = URL(string: fetchedResultsController.object(at: indexPath).imageUrl!)
            cell.imageView.kf.setImage(with: url)
            if let image = cell.imageView.image {
                let data = image.pngData()
                fetchedResultsController.object(at: indexPath).imageData = data
                try? dataController.viewContext.save()
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.deletePhoto(at: indexPath)
    }
    
    func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }

}
