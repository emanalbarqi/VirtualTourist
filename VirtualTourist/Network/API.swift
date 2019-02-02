//
//  API.swift
//  VirtualTourist
//
//  Created by Eman Albarqi on 23/01/2019.
//  Copyright © 2019 Eman Albarqi. All rights reserved.
//

import Foundation

class API {
    
    static    func searchPhootoForPinLocatio (latitude: Double, longitude: Double, completion: @escaping (_ result: PhotosInfo?, _ err:String?)->Void){
        
        // choosing a random page.
        var pageNumber: Int {
            let pageNumber = max(1,4000/APIConstants.FlickrParameterValues.PhotosPerPage)
            return Int(arc4random_uniform(UInt32(pageNumber)+1))
        }
        let bbox = bboxString(latitude: latitude, longitude: longitude)
        
        let methodParameters = [
            APIConstants.FlickrParameterKeys.Method: APIConstants.FlickrParameterValues.SearchMethod,
            APIConstants.FlickrParameterKeys.APIKey: APIConstants.FlickrParameterValues.APIKey,
            APIConstants.FlickrParameterKeys.BoundingBox: bbox,
            APIConstants.FlickrParameterKeys.SafeSearch: APIConstants.FlickrParameterValues.UseSafeSearch,
            APIConstants.FlickrParameterKeys.Extras: APIConstants.FlickrParameterValues.MediumURL,
            APIConstants.FlickrParameterKeys.Format: APIConstants.FlickrParameterValues.ResponseFormat,
            APIConstants.FlickrParameterKeys.NoJSONCallback: APIConstants.FlickrParameterValues.DisableJSONCallback,
            APIConstants.FlickrParameterKeys.Page           : "\(pageNumber)",
            APIConstants.FlickrParameterKeys.PhotosPerPage  : "\(APIConstants.FlickrParameterValues.PhotosPerPage)"
        ]
        
        var request = URLRequest(url: buildURLFromParameters(methodParameters))
        request.httpMethod = HTTPMethod.get.rawValue
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            //var studentLocations: [StudentLocation] = []
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    guard let data = data else {
                        errString = "Could not retrieve data."
                        return
                    }
                    
                    do {
                        let photosParser = try JSONDecoder().decode(PhotosInfo.self, from: data)
                        completion(photosParser, nil)
                    } catch {
                        errString = "Could not parse data"
                        completion(nil,errString)
                    }
                } else { //Err in parsing data
                    errString = "Couldn't parse response"
                    completion(nil,errString)
                }
            } else { //Request failed to sent
                errString = "Check your internet connection"
                completion(nil,errString)
            }
        }
        task.resume()
    }
    
    private static func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
            let minimumLon = max(longitude - APIConstants.Flickr.SearchBBoxHalfWidth, APIConstants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - APIConstants.Flickr.SearchBBoxHalfHeight, APIConstants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + APIConstants.Flickr.SearchBBoxHalfWidth, APIConstants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + APIConstants.Flickr.SearchBBoxHalfHeight, APIConstants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private static func buildURLFromParameters(_ parameters: [String: String]) -> URL {
        
        var components = URLComponents()
        components.scheme = APIConstants.Flickr.APIScheme
        components.host = APIConstants.Flickr.APIHost
        components.path = APIConstants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
