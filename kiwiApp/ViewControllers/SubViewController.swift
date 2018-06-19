//
//  SubViewController.swift
//  kiwiApp
//
//  Created by Tom Odler on 12.06.18.
//  Copyright © 2018 Tom Odler. All rights reserved.
//

import UIKit
import CoreData

class SubViewController: UIViewController,UITableViewDelegate ,UITableViewDataSource {
    @IBOutlet weak var flightImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var arriveTLbl: UILabel!
    
    @IBOutlet weak var departureTLbl: UILabel!
    @IBOutlet weak var depCountryLbl: UILabel!
    @IBOutlet weak var depCityLbl: UILabel!
    
    @IBOutlet weak var arrCountryLbl: UILabel!
    @IBOutlet weak var arrCityLbl: UILabel!
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityInt: UIActivityIndicatorView!
    
    var index : Int = 0
    private var transfers = [Transfer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.installObservers()
        
        let nib = UINib.init(nibName: "TransferTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "mCell")
        
        if let currentFlights = FlightManager.sharedManager.controller?.fetchedObjects {
            if(currentFlights.count == 5){
                self.makeTextVisible()
                let mFlight = currentFlights[index]
                self.showDetailsOfFlight(flight: mFlight)
            }
        }
        
        if(FlightManager.sharedManager.isSendingRequest){
            self.activityInt.isHidden = false
            self.activityInt.startAnimating()
        }
    }
    
    private func installObservers(){
    
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: Constants.notificationKeys.updateFlights), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.updateView()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: Constants.notificationKeys.requestDidEnd), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.activityInt.stopAnimating()
                self.activityInt.isHidden = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: Constants.notificationKeys.sendingFlightsRequest), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.activityInt.isHidden = false
                self.activityInt.startAnimating()
            }
        }
    }
    
    private func updateView(){
        let flights = FlightManager.sharedManager.flights
        guard let mFlights = flights else {
            print("Flight array empty")
            return
        }
        
        if mFlights.indices.contains(index) {
            self.makeTextVisible()
            let mFlight = mFlights[index]
            self.showDetailsOfFlight(flight: mFlight)
        }
    }
    
    private func makeTextVisible(){
        for label in labels {
            label.backgroundColor = .clear
            label.textColor = .black
        }
    }
    
    private func showDetailsOfFlight(flight: Flight){
        if let transfers = flight.transfers{
            self.transfers = Array(transfers) as! [Transfer]
            self.sortTransfers()
        }
        
        self.titleLbl.text = "\(flight.cityToName ?? "No data") - \(flight.countryToName ?? "")"
        self.priceLbl.text = "\(flight.price)\(flight.currency ?? "CZK")"
    
        self.departureTLbl.text = self.stringFromDate(date: flight.dTime!)
        self.arriveTLbl.text = self.stringFromDate(date: flight.aTime!)
        
        self.depCityLbl.text = flight.cityFromName
        self.depCountryLbl.text = flight.countryFromName
        
        let imageCodeString = "\(flight.cityToID ?? "prague")_\(flight.countryToCode?.lowercased() ?? "cz")"
        self.arrCountryLbl.text = flight.countryToName
        self.arrCityLbl.text = flight.cityToName
        NetworkManager.sharedManager.getImageDataFromURL(stringURL: "https://images.kiwi.com/photos/600/\(imageCodeString).jpg") { (data, error) in
            if let data = data {
                if data.count > 0 {
                    let image = UIImage.init(data: data)
                    DispatchQueue.main.async {
                        self.flightImg.image = image
                        self.flightImg.contentMode = .scaleAspectFill
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func stringFromDate(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY HH:mm"
        return formatter.string(from: date)
    }
    
    private func sortTransfers(){
        transfers.sort { (tr1, tr2) -> Bool in
            guard let date1 = tr1.aTime else {
                return false
            }
            
            guard let date2 = tr2.aTime else {
                return false
            }
            return date1 < date2
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transfers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mCell = tableView.dequeueReusableCell(withIdentifier: "mCell", for: indexPath) as? TransferTableViewCell
        if let tCell = mCell {
            let transfer = transfers[indexPath.row]
            tCell.aTimeLbl.text = self.stringFromDate(date: transfer.aTime!)
            tCell.dTimeLbl.text = self.stringFromDate(date: transfer.dTime!)
            tCell.cityFromLbl.text = transfer.cityFrom
//            tCell.flyFromLbl.text = transfer.flyFrom
            tCell.cityToLbl.text = transfer.cityTo
//            tCell.flyToLbl.text = transfer.flyTo
            return tCell
        } else {
            return UITableViewCell()
        }
    }
}
