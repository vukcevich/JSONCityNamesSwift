//
//  MapViewController.swift
//  
//
//  Created by Marijan Vukcevich on 3/12/15.
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // var checkPlace = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    // var annotations =  [NSMutableArray]()
    var locationManager = CLLocationManager()
    
    var startingPoint = CLLocation()

    var mapView = MKMapView()

    var myAddressArray = NSMutableArray()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        self.myStationLocaton()
        
        /*
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.startingPoint = [[CLLocation alloc] init]; //property that we store our current location
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 500;
        
        [self.locationManager startUpdatingLocation];
        
        // self.mapView.showsUserLocation = YES;
        
        // [self showCurrentLocation];
        
        [self getStationLocaton];
        */
    }
    
    func myStationLocaton() {
    
        var coordinate = CLLocationCoordinate2D(latitude: self.startingPoint.coordinate.latitude, longitude: self.startingPoint.coordinate.longitude) //CLLocationCoordinate2D
        var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var region = MKCoordinateRegion(center: coordinate, span: span)
        
        
        
        
        var firstCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) //CLLocationCoordinate2D
        
        var lat = self.myAddressArray[0] as CLLocationDegrees
        var log = self.myAddressArray[1] as CLLocationDegrees

        var str1:NSString = self.myAddressArray[2] as NSString
        var state:NSString = self.myAddressArray[3] as NSString
        var str2:NSString = self.myAddressArray[4] as NSString
        
        var finalStr = String(format: "%@, %@", str1, state )
        
        var milesStr = String(format: "%@ mi", str2 )
        // var listItems:NSArray = str0.componentsSeparatedByString(" ")
        var latitude = 0.0;
        var longitude = 0.0;
        
        
//        if(listItems.count >= 2)
//        {
//            latitude = listItems.objectAtIndex(0) as Double
//            longitude = listItems.objectAtIndex(1) as Double
//        }
        
        coordinate.latitude = lat
        coordinate.longitude = log
        
        // coordinate.latitude = latitude
        // coordinate.longitude = longitude
        
        firstCoordinate.latitude  = coordinate.latitude;
        firstCoordinate.longitude = coordinate.longitude;
    
     
        var annotation = ESIAnnotation(coordinate:firstCoordinate, title: finalStr, subtitle: milesStr)
        
        self.mapView.addAnnotation(annotation)
        
        span.latitudeDelta  = 0.29 //0.01;
        span.longitudeDelta = 0.29 //0.01;
        
        region.span = span
        region.center = firstCoordinate
        
        
        self.mapView.regionThatFits(region)
        self.mapView.showsUserLocation = true
        self.mapView.setRegion(region, animated:true)
        
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

   
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        //startingPoint = locations;
        var locationArray = locations as NSArray
        self.startingPoint = locationArray.lastObject as CLLocation
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        var errorType = (error.code == CLError.Denied.rawValue) ? "Access Denied" : "Unknown Error"
        
        println("error: \(errorType)")
        
        var alert =   UIAlertView.init(title:"Error Code:", message:errorType, delegate: self, cancelButtonTitle:"OK")
        
        alert.show()
        
         self.locationManager.stopUpdatingLocation()
    }
    
    
    
    func addAddress(address:NSMutableArray) {
        self.myAddressArray = address
    }
    
}
