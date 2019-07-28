//
//  ImagesViewController.swift
//  Virtual tourist
//
//  Created by Mac on 7/6/19.
//  Copyright © 2019 Eslam. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ImagesViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var lat : Double?
    var lon : Double?
    var coordinate : CLLocationCoordinate2D?
    let regionRadius: CLLocationDistance = 1000
    var pageNumber : Int!
    var dataController : DataController!
    var pinIcon : Pins!
    
    var images : [Images] = []{
        didSet{
            self.imagesCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.noImageLabel.isHidden = true
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        setUpMap()
        pageNumber = 1
        newCollectionButton.setTitleColor(#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1), for: .normal)

        let fetchRequest:NSFetchRequest <Images> = Images.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pinIcon)
        fetchRequest.predicate = predicate
        
        print (self.lat!, self.lon!)
        
      Flicker.displayImageFromFlickrBySearch(withPageNumber: pageNumber, lat: self.lat!, lon: self.lon!, completion: handleResponse(status:imageUrlString:error:))
//        if pinIcon.images?.count == 0 {
//            print ("no saved images For this PinIcon")
//            print ("DOWNLOADING ....")
//            downloadImages(pageNumber: pageNumber)
//        }else {
//            if let result = try? dataController.viewContext.fetch(fetchRequest){
//                images = result
//            }
//        }
        
 
        
    }
    func handleResponse(status: Int, imageUrlString: String , error: Error?) {
        
        if status == 1{
            print ("status == 1")
            let image : Images
            image = Images(context: self.dataController.viewContext)
            image.url = imageUrlString
            image.pin = self.pinIcon
            try? self.dataController.viewContext.save()
        } else {
            print ("status == 0")
            
            self.imagesCollectionView.isHidden = true
            self.noImageLabel.isHidden = false
            self.noImageLabel.text = "No Photos Found. Search Again."
            
        }
    }

    @IBAction func newCollectionButtonPressed (_sender : Any){
        pageNumber += 1
        newCollectionButton.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
        newCollectionButton.isEnabled = false
        print (pageNumber!)
        //downloadImages(pageNumber: pageNumber!)
        Flicker.displayImageFromFlickrBySearch(withPageNumber: pageNumber, lat: self.lat!, lon: self.lon!, completion: handleResponse(status:imageUrlString:error:))
        newCollectionButton.setTitleColor(#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1), for: .normal)
        newCollectionButton.isEnabled = true
    }

    func setUpMap (){
        self.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        mapView.addAnnotation(annotation)
        
        let initialLocation = CLLocation(latitude: self.lat!, longitude: self.lon!)
        centerMapOnLocation(location: initialLocation)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setCenter(self.coordinate!, animated: true)
    }
    
    
    
}





extension ImagesViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageToDelete = images[(indexPath as NSIndexPath).row]
        dataController.viewContext.delete(imageToDelete)
        try? dataController.viewContext.save()
        images.remove(at: indexPath.row)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
        
        cell.imageView?.image = UIImage(named: "placeHolder")
        
        if self.images.count != 0 {
        let imageUrl = self.images[(indexPath as NSIndexPath).row]
            if let url = URL(string: imageUrl.url ?? ""){
            let logoImage = try? Data(contentsOf: url)
                if let logoImage = logoImage{
                    cell.imageView!.image = UIImage(data: logoImage)
                }
            }
        }
        return cell
    }
}

