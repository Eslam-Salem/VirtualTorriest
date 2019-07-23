//
//  ViewController.swift
//  Virtual tourist
//
//  Created by Eslam  on 5/11/19.
//  Copyright © 2019 Eslam. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var informationLabel: UILabel!

    
    let longtiudeKey = "map Center Longtiude"
    let latitudeKey = "map Center Latitude"
    let zoomKey = "zoom Key"

    var pinIcons : [Pins] = []
    var dataController : DataController!
    var fetchedResultsController:NSFetchedResultsController<Pins>!
    var flag = false
    var selectedAnnotation: MKPointAnnotation?


    override func viewDidLoad() {
        super.viewDidLoad()
        //define a long gesture and add it to the mapview

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(longGesture:)))
        mapView.addGestureRecognizer(longGesture)
        mapView.centerCoordinate.latitude = UserDefaults.standard.double(forKey: latitudeKey)
        mapView.centerCoordinate.longitude = UserDefaults.standard.double(forKey: longtiudeKey)
        mapView.visibleMapRect.size.width = UserDefaults.standard.double(forKey: zoomKey)
        mapView.delegate = self
        setupView(flag: false)
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.flag = false
    }
    
    @IBAction func editButtonPressed ( _ sender : Any){
        self.flag = !self.flag
        setupView(flag: self.flag)
    }
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Pins> = Pins.fetchRequest()
        
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pinIcons = result
            for i in pinIcons{
            let annotation = MKPointAnnotation()
            let lat = i.latitude
            let lon = i.longitude
            let points = CLLocationCoordinate2DMake(lat, lon)
            annotation.coordinate = points
            mapView.addAnnotation(annotation)
            }
        }
    }

    
    func setupView (flag : Bool) {
        if flag{
            self.editButton.title = "Done"
            self.informationLabel.isHidden = false
        }else {
            self.editButton.title = "edit"
            self.informationLabel.isHidden = true
        }
    }
  
    @objc func addAnnotation (longGesture: UIGestureRecognizer){
        //get the location of the gesture in the mapview then convert it to coordinate
        let touchPoint = longGesture.location(in: mapView)
        let points = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        //add the anootaion at the corrdinate returned
        let annotation = MKPointAnnotation()
        annotation.coordinate = points
        annotation.title = "hi"
        mapView.addAnnotation(annotation)
        // persist icons
        let iconPin = Pins(context: dataController.viewContext)
        iconPin.latitude = points.latitude
        iconPin.longitude = points.longitude
        try? dataController.viewContext.save()
    }
}





extension MapViewController : MKMapViewDelegate {
    
    // what will happen when tap on the pin
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Float(log2(zoomWidth)) - 9
        let center = mapView.centerCoordinate
        UserDefaults.standard.set(center.longitude, forKey: longtiudeKey)
        UserDefaults.standard.set(center.latitude, forKey: latitudeKey)
        UserDefaults.standard.set(zoomFactor, forKey: zoomKey)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if flag {
            // persist icons
            for iconToDelet in pinIcons{
                if iconToDelet.latitude == view.annotation?.coordinate.latitude && iconToDelet.longitude == view.annotation?.coordinate.longitude{
                    
                    dataController.viewContext.delete(iconToDelet)
                    try? dataController.viewContext.save()
                }
            }
            mapView.removeAnnotation(view.annotation!)
        }else {

        let Vc = self.storyboard?.instantiateViewController(withIdentifier: "ImagesViewController") as? ImagesViewController
            
            print(view.annotation?.coordinate.longitude)
            print( view.annotation?.coordinate.latitude)
            
            Vc?.lon = view.annotation?.coordinate.longitude
            Vc?.lat = view.annotation?.coordinate.latitude
            
            for foundPin in pinIcons{
                if foundPin.latitude == view.annotation?.coordinate.latitude && foundPin.longitude == view.annotation?.coordinate.longitude{
    
                    Vc?.pinIcon = foundPin
                }
            }

            
            Vc?.dataController = dataController
            self.navigationController?.pushViewController(Vc!, animated: true)
        }
    }
    
}

