//
//  parseClient.swift
//  virtual-torrest
//
//  Created by Eslam  on 4/17/19.
//  Copyright © 2019 Eslam. All rights reserved.
//

import Foundation

class Flicker {
    
    class func bboxString(lat : Double , lon : Double) -> String {
        return "\(lon) , \(lat) , \(lon), \(lat)"
}

class func displayImageFromFlickrBySearch(withPageNumber: Int ,lat: Double , lon: Double, completion: @escaping (Int, String ,Error?) -> Void) {
    
    
    let methodParametersWithPageNumber = [
        Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
        Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
        Constants.FlickrParameterKeys.BoundingBox: bboxString(lat: lat, lon: lon),
        Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
        Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
        Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
        Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
        Constants.FlickrParameterKeys.Page: withPageNumber
        ] as [String : Any]
    

    
    // create session and request
    let session = URLSession.shared
    let request = URLRequest(url: flickrURLFromParameters(methodParametersWithPageNumber as [String : AnyObject]))
    
    print (request)
    // create network request
    let task = session.dataTask(with: request) { (data, response, error) in
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            self.displayError("There was an error with your request: \(error)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            self.displayError("Your request returned a status code other than 2xx!")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            self.displayError("No data was returned by the request!")
            return
        }
        
        // parse the data
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            self.displayError("Could not parse the data as JSON: '\(data)'")
            return
        }
        
        /* GUARD: Did Flickr return an error (stat != ok)? */
        guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
            self.displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
            return
        }
        
        /* GUARD: Is the "photos" key in our result? */
        guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
            self.displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
            return
        }
        
        /* GUARD: Is the "photo" key in photosDictionary? */
        guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
            self.displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
            return
        }
        
        if photosArray.count == 0 {
            self.displayError("No Photos Found. Search Again.")
            DispatchQueue.main.async {
                completion(0 , "" ,nil)

//                self.imagesCollectionView.isHidden = true
//                self.noImageLabel.isHidden = false
//                self.noImageLabel.text = "No Photos Found. Search Again."
            }
            return
            
        } else {
            print ("photos array",photosArray.last)
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
            let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
            
            /* fill the array of images url */
            for i in photosArray{
                
                guard let imageUrlString = i[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    self.displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
                print (imageUrlString)
                completion(1, imageUrlString, nil)

            }
            
        }
    }
    task.resume()
}



class func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = Constants.Flickr.APIScheme
    components.host = Constants.Flickr.APIHost
    components.path = Constants.Flickr.APIPath
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
    }
    print(components.url!)
    return components.url!
    
    }

class func displayError(_ error: String) {
    print(error)
    }
}
