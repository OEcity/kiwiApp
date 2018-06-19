//
//  FlightManager.swift
//  kiwiApp
//
//  Created by Tom Odler on 26.05.18.
//  Copyright © 2018 Tom Odler. All rights reserved.
//

import UIKit
import CoreData

class FlightManager: NSObject ,NSFetchedResultsControllerDelegate{
    static let sharedManager = FlightManager()
    var flights : [Flight]?
    var controller : NSFetchedResultsController<Flight>?
    var isSendingRequest = false
    private let defaults = UserDefaults.standard
    
    override init() {
        super.init()
        
        self.initFetcher()
    }
    
    func checkTodayOffer(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let lastDate = defaults.object(forKey: Constants.userDictionaryKeys.dateKey){
            if formatter.string(from: lastDate as! Date) == formatter.string(from: Date()){
                //pokud uz jsem dnes nacital, nenacitam nove nabidky
                return;
            }
        }
        defaults.set(Date(), forKey: Constants.userDictionaryKeys.dateKey)
        
        let locale = Locale.current as NSLocale
        let countryCode = locale.countryCode ?? "CZ"
        let currency = locale.currencyCode ?? "CZK"
        
        let date = Date()
        
        let cal = Calendar.current
        let newDate = cal.date(byAdding: .month, value: 1, to: date)
        
        let result = formatter.string(from: date)
        let result2 = formatter.string(from: newDate ?? date)
        
        print("current locale \(countryCode) currency \(currency) date \(result) newDate \(result2)")
        isSendingRequest = true
        
        NotificationCenter.default.post(name:  Notification.Name(rawValue: Constants.notificationKeys.sendingFlightsRequest), object: nil, userInfo: nil)
        
        NetworkManager.sharedManager.getFlightDataFromUrl(stringUrl: "https://api.skypicker.com/flights?flyFrom=\(countryCode)&to=&dateFrom=\(result)&dateTo=\(result2)&curr=\(currency)&limit=200") { (data, errorResponse) in
            if let data = data {
                CoreDataManager.sharedManager.deleteOldFlights()
                self.isSendingRequest = false
                
                print("got data")
                let flights = data["data"] as! [[String : Any]]
                let currency = data["currency"] as! String
                
                self.storeTodayFlights(flightsArray: flights, currency: currency)
            }
            
            if let error = errorResponse {
                print("error \(error.error.debugDescription)")
            }

            NotificationCenter.default.post(name:  Notification.Name(rawValue: Constants.notificationKeys.requestDidEnd), object: nil, userInfo: nil)
        }
    }
    
    private func storeTodayFlights(flightsArray : [Dictionary<String, Any>], currency : String){
        var chosenFlightsArray  = [[String : Any]]()

        while chosenFlightsArray.count < 5 {
            let randomNumber =  Int(arc4random_uniform(UInt32(flightsArray.count)))
            chosenFlightsArray.append(flightsArray[randomNumber])
        }
        
        for flightDetail  in chosenFlightsArray {
            let flightDetail = flightDetail as [String : Any]
            
            let newFlight = CoreDataManager.sharedManager.createFlight()
            newFlight.cityToID = flightDetail["mapIdto"] as? String
            newFlight.cityToName = flightDetail["cityTo"] as? String
            newFlight.currency = currency
            newFlight.price = flightDetail["price"] as! Double
            newFlight.cityFromName = flightDetail["cityFrom"] as? String
            
            let countryFromDetail = flightDetail["countryFrom"] as! [String : Any]
            newFlight.countryFromName = countryFromDetail["name"] as? String
            
            let arrayOfRoute = flightDetail["route"] as! [[String : Any]]
            if(arrayOfRoute.count > 0){
                for routeDetail in arrayOfRoute {
                    let transfer = CoreDataManager.sharedManager.createTransfer()
                    transfer.flight = newFlight
                    
                    transfer.dTime = self.getDateFromTimestamp(timestamp: routeDetail["dTimeUTC"] as! NSNumber)
                    transfer.aTime = self.getDateFromTimestamp(timestamp: routeDetail["aTimeUTC"] as! NSNumber)
                    transfer.cityFrom = routeDetail["cityFrom"] as? String
                    transfer.cityTo = routeDetail["cityTo"] as? String
                    transfer.flyFrom = routeDetail["flyFrom"] as? String
                    transfer.flyTo = routeDetail["flyTo"] as? String
                }
            }
            
            newFlight.dTime = self.getDateFromTimestamp(timestamp: flightDetail["dTimeUTC"] as! NSNumber)
        
            newFlight.aTime = self.getDateFromTimestamp(timestamp: flightDetail["aTimeUTC"] as! NSNumber)
              
            
            let countryToDetail = flightDetail["countryTo"] as! [String : Any]
            newFlight.countryToCode = countryToDetail["code"] as? String
            newFlight.countryToName = countryToDetail["name"] as? String
        }
        CoreDataManager.sharedManager.saveContext()
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.notificationKeys.updateFlights) , object: nil)
    }
    
    private func getDateFromTimestamp(timestamp : NSNumber) -> Date?{
        let dTimestamp = timestamp as! Double
        let newDate = Date.init(timeIntervalSince1970: TimeInterval(dTimestamp))
        return newDate
    }
    
    private func initFetcher(){
        let context = CoreDataManager.sharedManager.context
        
        if let context = context{
            let fRequest = NSFetchRequest<Flight>.init(entityName: "Flight")
            
            let descriptor = NSSortDescriptor.init(key: "countryToName", ascending: true)
            fRequest.sortDescriptors = [descriptor]
            
            controller = NSFetchedResultsController(fetchRequest: fRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            controller!.delegate = self
            do {
                try controller!.performFetch()
                print("Number of flights: \(controller!.fetchedObjects!.count)")
                
            } catch {
                print("nepovedlo se načíst unselected jobs! \(error)")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let mFlights = controller.fetchedObjects {
//            print("sending notification")
            flights = mFlights as? [Flight]
            if controller.fetchedObjects?.count == 5 {
                
            }
        }
    }
}
