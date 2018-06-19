//
//  NetworkManager.swift
//  kiwiApp
//
//  Created by Tom Odler on 26.05.18.
//  Copyright © 2018 Tom Odler. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    static let sharedManager = NetworkManager()
    private let mainQueue = OperationQueue()
    
    func getFlightDataFromUrl(stringUrl : String, completion: @escaping([String:Any]?, errorResponse?) -> ()){
        guard let finalURL = URL(string: stringUrl) else {
            return
        }
        
        let request = self.getRequestWithURL(url: finalURL, httpMethod: "GET")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                if let json = json{
                    completion(json, errorResponse())
                }
            }
            
            if let error = error {
                let response = errorResponse.init(response: urlResponse, error: error)
                completion(nil,response)
            }
        }
        task.resume()
    }
    
    func getImageDataFromURL(stringURL : String, completion: @escaping(Data?, errorResponse?) -> ()) {
        guard let finalURL = URL(string: stringURL) else {
            return
        }
        
        let request = self.getRequestWithURL(url: finalURL, httpMethod: "GET")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
//                print("statusCode: \(httpResponse.statusCode)")
                if(httpResponse.statusCode != 200){
                    let response = errorResponse.init(response: urlResponse, error: error)
                    completion(nil,response)
                } else {
                    if let data = data {
                        completion(data,nil)
                    }
                }
            }
 
            if let error = error {
                let response = errorResponse.init(response: urlResponse, error: error)
                completion(nil,response)
            }
        }
        task.resume()
    }
    
    private func getRequestWithURL(url : URL!, httpMethod : String!) -> NSMutableURLRequest{
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = httpMethod
        request.timeoutInterval = 20
        
        return request
    }
    
    
}

struct errorResponse {
    var response : URLResponse?
    var error : Error?
}
