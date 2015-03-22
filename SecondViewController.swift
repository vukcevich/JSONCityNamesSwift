//
//  SecondViewController.swift
//  
//
//  Created by Marijan Vukcevich on 3/7/15.
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SecondViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    var checkPlace = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var annotations = NSMutableArray()

    var locationManager = CLLocationManager()
    var startingPoint = CLLocation()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var myAddressArray =  NSMutableArray()
    var savedStationsFromFile =  NSArray()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.delegate = self
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        // Path to save array data
        var arrayPath = documentsPath.stringByAppendingPathComponent("StationsRecordsArray.out");
        
        self.savedStationsFromFile =  NSArray(contentsOfFile: arrayPath)!
        
        self.locationManager = CLLocationManager()
        //  NSLog(@"self.locMgr: %@", self.locMgr);
        // set its delegate
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.startingPoint = CLLocation() //property that we store our current location
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if self.locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.locationManager.distanceFilter = 500
        
        self.locationManager.startUpdatingLocation()

         self.showCurrentLocation()
        
        self.getLocations()
        
        
    }

    func showCurrentLocation() {
    
        
        self.mapView.showsUserLocation = true
        
        // Set pickupLocation to current location of the user
        var location = self.startingPoint.coordinate
        //this did not work
        // var location:CLLocationCoordinate2D = self.mapView.userLocation.location.coordinate
        
        var stCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) //CLLocationCoordinate2D
        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var region = MKCoordinateRegion(center: stCoordinate, span: span)
        
        span.latitudeDelta  = 0.01;
        span.longitudeDelta = 0.01;
        
       
        
        region.span = span
        region.center = location
        
        self.mapView.setRegion(region, animated:true)
        
}
    
    func getLocations() {
    
        //  self.mapView.delegate = self
     
        //  if(annotations != nil) {
        //    return
        // }
        
       for d in self.savedStationsFromFile {
        
        
        var coor: NSMutableDictionary = d.objectForKey("coordinate") as  NSMutableDictionary
        
        var dblat = coor.objectForKey("latitude") as Double
        checkPlace.latitude = dblat
        var dblng = coor.objectForKey("longitude") as Double
        checkPlace.longitude = dblng 
        
        //   var stTitle = d.objectForKey("callSign") as NSString
          var stTitle = d.objectForKey("cityname") as NSString
         var stState = d.objectForKey("state") as NSString
        
        var finalStr = String(format: "%@, %@", stTitle, stState )
        
        var miles = d.objectForKey("miles") as Double
        var stMiles = NSString(format: "%.2f mi", miles)
        var annotation = ESIAnnotation(coordinate:checkPlace, title: finalStr , subtitle: stMiles)
        
        self.mapView.addAnnotation(annotation)

        annotations.addObject(annotation)
        
       }
       
        
        var flyTo:MKMapRect = MKMapRectNull
        for ant in annotations {
            var annotationPoint:MKMapPoint = MKMapPointForCoordinate(ant.coordinate)
            var pointRect:MKMapRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
            if (MKMapRectIsNull(flyTo)) {
                flyTo = pointRect;
            } else {
                flyTo = MKMapRectUnion(flyTo, pointRect);
            }
        }
        
     self.mapView.setVisibleMapRect(flyTo, animated:true)
        
}
    
    
    func mapView(mapView:MKMapView!, viewForAnnotation annotation:MKAnnotation!) -> MKAnnotationView!  {
        
        
        
        let AnnotationIdentifier = "AnnotationIdentifier1"
        var pinView = MKPinAnnotationView(annotation:annotation, reuseIdentifier: AnnotationIdentifier)
        
        if annotation.isKindOfClass(MKUserLocation) { return nil }
        
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.pinColor = MKPinAnnotationColor.Purple
        
        //var profileIconView:UIImageView  = UIImageView(initWithImage:UIImage.imageNamed("profile.png"))
        
        var profileIconView:UIImageView  = UIImageView(image:UIImage.init(named:"profile.png"))
        
        pinView.leftCalloutAccessoryView = profileIconView;
        
        return pinView
        
    }
   
    
    
    
    
    func mapView(mapView:MKMapView!, didUpdateUserLocation userLocation:MKUserLocation) {
        self.mapView.centerCoordinate = userLocation.location.coordinate
    }
    

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        //startingPoint = locations;
        var locationArray = locations as NSArray
        self.startingPoint = locationArray.lastObject as CLLocation
        
    }
   /*
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
    */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        var errorType = (error.code == CLError.Denied.rawValue) ? "Access Denied" : "Unknown Error"
        
        println("error: \(errorType)")
        
        var alert =   UIAlertView.init(title:"Error Code:", message:errorType, delegate: self, cancelButtonTitle:"OK")
        
        alert.show()
        
        self.locationManager.stopUpdatingLocation()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

