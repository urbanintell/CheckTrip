//
//  ETAController.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/26/16.
//  Copyright © 2016 Lusenii Kromah. All rights reserved.
//

import UIKit
import MapKit

class ETAController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{

    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
     var googleMapsETA:String?
    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var dateTime:String?
    
    var flight:Flight!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        
        
        
        getGoogleETA()
        etaLabel.text = flight.departureTime
        
        
  
        
        configureMap()

        
        
    }
    

    
    func configureMap(){
    
        mapView.delegate = self
        mapView.showsUserLocation = true
        let latDelta: CLLocationDegrees = 0.5
        let lonDelta: CLLocationDegrees = 0.5
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapView.setRegion(region, animated: true)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    
    func getGoogleETA(){
        guard let airportAddreess = flight.departureAirportAddress else {
            return
        }
        print(airportAddreess)
        CLGeocoder().geocodeAddressString(airportAddreess) { (placemark:[CLPlacemark]?, error:Error?) in
            if error != nil{
                return
            }
            
            
            guard let place = placemark else {
                
                return
            }
            let airportLat = Double((place[0].location?.coordinate.latitude)!)
            let airportLng = Double((place[0].location?.coordinate.longitude)!)
            
            

             var timeToAirport =  self.computeDuration(self.latitude, originLongitude: self.longitude, destinationLatitude: airportLat, destinationLongitude: airportLng)
     
        }
    
    }

    
    func computeDuration(_ originLatitude:Double,originLongitude:Double,destinationLatitude: Double,destinationLongitude:Double)  {
        
        
        
        
        let request = URLRequest(url: URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLatitude),\(originLongitude)&destination=\(destinationLatitude),\(destinationLongitude)&key=AIzaSyBqB5Y5Ex9n5V33EQ283eC3CXv2UTRckwA")! )
        
        //show Directions on map
        let origin = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let destination = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
        showDirections(origin: origin, destination: destination)
        
        
        print(request)
        
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request , completionHandler: {
            (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                
                
                print(data)
                self.googleMapsETA =  self.parseJsonData(data)
                
                
            }
        })
        
        
        task.resume()
        
        
        
    }
    
    func parseJsonData(_ data: Data) -> String {
        var ETA:String?
        do{
            let directionsResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            
            
            
            let routes = directionsResult?["routes"] as! [AnyObject]
            let directions = routes[0] as! [String:AnyObject]
            let leg = directions["legs"] as! [AnyObject]
            let legResults = leg[0] as! [String:AnyObject]
            let duration = legResults["duration"] as! [String:AnyObject]
            
            
            ETA = duration["text"] as? String
            let min = Int((ETA?.components(separatedBy: " ")[0])!)
            
            print("TIME: \(min)")
            subtractGoogleMapsEta(subtract:min!)
            
        }catch {
            print(error)
        }
        
        return ETA!
    }
    
    
    //convert string time to a real time
    func subtractGoogleMapsEta(subtract:Int) {
        
        
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        formatter.dateFormat = "hh:mm a"
        //get time from etaLabel and convert it to a date
        if let parsedDateTimeString = formatter.date(from: etaLabel.text!) {
             //subtract ETA from time
            let etaDate = parsedDateTimeString.addingTimeInterval(TimeInterval(180 * -subtract))
            print(etaDate)
            
          
            
            OperationQueue.main.addOperation {
                
                self.etaLabel.text = formatter.string(from: etaDate)
                self.spinner.stopAnimating()
            }

        } else {
            print("Could not parse date")
        }
        
   
        
        
    }
    
    
    func showDirections(origin:CLLocationCoordinate2D, destination:CLLocationCoordinate2D) {
        let currentPlace: MKPlacemark = MKPlacemark(coordinate: origin)
        
        let place: MKPlacemark = MKPlacemark(coordinate: destination)
        
        
        
        print(currentPlace.coordinate.latitude)
        print(currentPlace.coordinate.longitude)
        print(place.coordinate.latitude)
        print(place.coordinate.longitude)
        
        var request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = MKMapItem(placemark: currentPlace)
        request.destination = MKMapItem(placemark: place)
        
        request.transportType = .any
        request.requestsAlternateRoutes = true
        var directions: MKDirections = MKDirections(request: request)
        directions.calculate() {
            (response, error) in
            if(error == nil && response != nil) {
                for route in (response?.routes)! {
                    let r: MKRoute = route 
                    self.mapView.add(r.polyline, level: MKOverlayLevel.aboveRoads)
                }
            }
        }
        
        
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
    
 
    
 
    
    

   
}
