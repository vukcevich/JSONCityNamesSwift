//
//  FirstViewController.swift
//  
//
//  Created by Marijan Vukcevich on 3/7/15.
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//

import UIKit
import CoreLocation

class FirstViewController: UITableViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    var locMgr:CLLocationManager!
    var startingPoint:CLLocation!
    
    // var dictAllCities = Dictionary<String, String>()
    
    var stationsRecordsArray = NSMutableArray()
    var combinedJsonArrays = NSMutableArray()

    @IBOutlet var stationTableView:UITableView?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        println("DEBUG: INIT ------- ")
        
        //Initialize CLLocation Manager so we can get location and calculate distance
        locMgr = CLLocationManager()
        //  NSLog(@"self.locMgr: %@", self.locMgr);
        // set its delegate
        locMgr.delegate = self
        locMgr.desiredAccuracy = kCLLocationAccuracyBest
        startingPoint = CLLocation() //property that we store our current location
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if locMgr.respondsToSelector(Selector("requestWhenInUseAuthorization")) {
            locMgr.requestWhenInUseAuthorization()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//        // Path to save array data
//        var arrayPath = documentsPath.stringByAppendingPathComponent("CombinedJsonArray.out");

//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//        // Path to save array data
//        var arrayPath = documentsPath.stringByAppendingPathComponent("CombinedJsonArray.out");
//        
//        if NSFileManager.defaultManager().fileExistsAtPath(arrayPath) {
//            self.combinedJsonArrays =  NSMutableArray(contentsOfFile: arrayPath)!
//        }
          self.getStationsJsonData()
        
    }

    override func viewWillAppear(animated: Bool) {
    
    super.viewWillAppear(true)
}
    
    
    func getStationsJsonData() {
    
        var d2 = NSMutableArray()
        
      
         var path = NSBundle.mainBundle().pathForResource("cities_with_states_json1", ofType: "json")
        println("dbg: path: \(path)")
        
        
        var error: NSError?
        var jsonData = NSData(contentsOfFile:path!, options: nil, error: &error)
        // println("jsonData \(jsonData)") // This prints what looks to be JSON encoded data.
        
        if((error) != nil) {
           println("Error: \(error)")
        }
        
        var jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSMutableDictionary
        // println("jsonDict \(jsonDict)")
        
        
         combinedJsonArrays = jsonDict!.valueForKey("places") as NSMutableArray
        println("combinedJsonArrays: \(combinedJsonArrays)")
        
        
        
         let path2 = NSBundle.mainBundle().pathForResource("cities_with_states_json2", ofType: "json")
        var error2: NSError?
        var jsonData2 = NSData(contentsOfFile:path2!, options: nil, error: &error2)
        // println("jsonData \(jsonData)") // This prints what looks to be JSON encoded data.
        
        if((error2) != nil) {
            println("Error: \(error2)")
        }
        
        var jsonDict2 = NSJSONSerialization.JSONObjectWithData(jsonData2!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSMutableDictionary
        // println("jsonDict2 \(jsonDict2)")
        
       
        d2 = jsonDict2!.valueForKey("places") as NSMutableArray
        println("d2: \(d2)")
        
        
        combinedJsonArrays.addObjectsFromArray(d2)
        
        println("combinedJsonArrays.count: \(combinedJsonArrays.count)")
        println("Final(combinedJsonArrays): \(combinedJsonArrays)")
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        // Path to save array data
        var arrayPath = documentsPath.stringByAppendingPathComponent("CombinedJsonArray.out");
        
              var isB = combinedJsonArrays.writeToFile(arrayPath, atomically:true)
                if(isB) {
                   println("Saved to file")
                } else {
                   println("Not saved to file - ")
                }
        
}
    

func calculateDistanceForData() {
    
    
    
    //Note: If it's null we can not get correct distance for stations latitude and longitude
    startingPoint = self.locMgr.location;
    println("dbg -(check point -  self.startingPoint: \(startingPoint.coordinate.latitude)  :  \(startingPoint.coordinate.longitude)")
    
    //store the values in variables so we can reuse their values for calculation
    var latB = startingPoint.coordinate.latitude;
    var logB = startingPoint.coordinate.longitude;
    
    println("latB: \(latB)");
    println("logB: \(logB)");
    

    for item in combinedJsonArrays {
        
        
            var dictAllCities = NSMutableDictionary()
            
            var d: NSMutableDictionary = item.objectForKey("coordinate") as NSMutableDictionary
            
        //NSLog(@"check latitude: %@", [d objectForKey:@"latitude"]);
        //NSLog(@"check longitude: %@", [d objectForKey:@"longitude"]);
        
        //get latitude and longitude values for each station
        var latA: CLLocationDegrees = d.objectForKey("latitude") as CLLocationDegrees
        var logA: CLLocationDegrees = d.objectForKey("longitude") as CLLocationDegrees
        
        var jsonStations = CLLocation(latitude: latA, longitude: logA)
        
        var localStartingPoint = CLLocation(latitude:latB, longitude:logB)
        
        //1 Meter = 0.000621371192 Miles
        //1 Mile = 1609.344 Meters
            var distanceInMeters = localStartingPoint.distanceFromLocation(jsonStations)
        //convert it to miles
        var miles = distanceInMeters / 1609.344;
        
        //create dictionary
        dictAllCities.setValue(item.objectForKey("cityname"), forKey:"cityname")
        dictAllCities.setValue(item.objectForKey("state"), forKey:"state")
        dictAllCities.setObject(d, forKey:"coordinate") //we need to added back, so we can use the values for MapKit
        dictAllCities.setValue(miles, forKey:"miles") //we use nsnumber it will help us with sorting, string did not work
        //add each dictionary to array
        self.stationsRecordsArray.addObject(dictAllCities)
       
    }
    
    //Note: our newRecordsArray with stations and their distances in miles
    //  NSLog("\n\n111-dbg - self.stationsRecordsArray: \(self.stationsRecordsArray)\n\n\n");
     NSLog("\n\n1222-dbg - self.stationsRecordsArray.count: \(self.stationsRecordsArray.count)\n\n\n");
    
    
    //Sort Array by miles so we can display the closest station
     var descriptor: NSSortDescriptor = NSSortDescriptor(key: "miles", ascending: true)
     self.stationsRecordsArray.sortUsingDescriptors([descriptor])
    
    
    //our sorted array as per distance
    println("\n\n\ndbg:sorted(self.stationsRecordsArray): \(self.stationsRecordsArray)");
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    // Path to save array data
    var arrayPath = documentsPath.stringByAppendingPathComponent("StationsRecordsArray.out")

//     if !NSFileManager.defaultManager().fileExistsAtPath(arrayPath) {
    // var isB = self.stationsRecordsArray.writeToFile(arrayPath, atomically:true)
     var isB = self.stationsRecordsArray.writeToFile(arrayPath, atomically:false)
        if(isB) {
            println("stationsRecordsArray - saved to file")
        } else {
            println("st - Not saved to file - ")
        }
    //}
    
}

    
    
    
   override func tableView(tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return self.stationsRecordsArray.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        //var cell = tableView.dequeueReusableCellWithIdentifier:"StationsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier("StationsCell", forIndexPath: indexPath) as UITableViewCell
        
        // NSLog(@"----self.stationsRecordsArray: %@", self.stationsRecordsArray);
        println("cell - self.stationsRecordsArray: \(self.stationsRecordsArray)")
        
       
        var d: NSMutableDictionary = self.stationsRecordsArray[indexPath.row] as NSMutableDictionary
        
        // var modifiedURLString = NSString(format:"http://%@", urlString) as String
        // let books = dict.objectForKey("Books")! as [[String:AnyObject]]
        //    cell.textLabel?.text = d.objectForKey("callSign") as? String //String("%@", d.objectForKey("callSign"));
        var str = String( format: "%@, %@", d.objectForKey("cityname") as String, d.objectForKey("state") as String )
        //  cell.textLabel?.text = d.objectForKey("cityname") as? String //String("%@", d.objectForKey("callSign"));
         cell.textLabel?.text = str
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(18)
        var mileDistance = d.objectForKey("miles") as Double
        cell.detailTextLabel?.text = String(format: "%.2f mi", mileDistance)
        
            
            
     return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0;
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "showMapView") {
            // pass data to next view
            
            // let cell = sender as UITableViewCell
            if var indexPath = stationTableView!.indexPathForSelectedRow() {
            
        
            var d: NSDictionary = self.stationsRecordsArray.objectAtIndex(indexPath.row) as NSDictionary
            
            var cor:NSMutableDictionary = d.objectForKey("coordinate") as NSMutableDictionary
            
                println("dbg: cor: \(cor)")
                
               
                var lat = cor.objectForKey("latitude") as Double
                var log = cor.objectForKey("longitude") as Double
                // var latlongValue: NSString = NSString( format:"%f %f", lat , log )
            
                //var stationName = d.objectForKey("callSign") as NSString
            var cityName = d.objectForKey("cityname") as NSString
             var stateName = d.objectForKey("state") as NSString
            var dist = d.objectForKey("miles") as Double
            var distance = NSString(format:"%.2f", dist)
           
                var myArray	= NSMutableArray()
                var packArray = NSMutableArray()
                
                packArray.addObject(lat)
                packArray.addObject(log)
                packArray.addObject(cityName)
                packArray.addObject(stateName)
                packArray.addObject(distance)
                myArray.addObject(packArray)
                
                var myMap:MapViewController = segue.destinationViewController as MapViewController
                myMap.myAddressArray = packArray
                
            }
        }
    }
    
    // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    //    if segue.identifier  {
        
        
//    if ([segue.identifier isEqualToString:"showMapView"]) {
//        // NSLog(@"DEBUG");
//    NSIndexPath *indexPath = [self.stationTableView indexPathForSelectedRow];
//    
//    
//    NSDictionary * d = [self.stationsRecordsArray objectAtIndex:[indexPath row]];
//    
//    NSLog(@"dbg: d(selected): %@", d);
//    //NSUInteger row		= [indexPath row];
//    NSMutableDictionary* cor = [d objectForKey:@"coordinate"];
//    NSString* latlongValue = [NSString stringWithFormat:@"%@ %@", [cor objectForKey:@"latitude"], [cor objectForKey:@"longitude"]];
//    NSString *stationName = [d objectForKey:@"callSign"];
//    double dist = [[d objectForKey:@"miles"] doubleValue];
//    NSString* distance = [NSString stringWithFormat:@"%.2f", dist];
//    
//    
//    NSMutableArray* myArray		= [[NSMutableArray alloc] init];
//    NSMutableArray* packArray	= [[NSMutableArray alloc] init];
//    
//    [packArray addObject:latlongValue];
//    [packArray addObject:stationName];
//    [packArray addObject:distance];
//    [myArray addObject:packArray];
//    
//    MapViewController *myMap = segue.destinationViewController;
//    NSLog(@"packArray: %@", packArray);
//    myMap.myAddressArray = packArray;
//    NSLog(@"dbg: myMap.myAddressArray: %@", myMap.myAddressArray);
        //    }

    //}

    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
        //startingPoint = locations;
         var locationArray = locations as NSArray
        startingPoint = locationArray.lastObject as CLLocation
        
        
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
       var errorType = (error.code == CLError.Denied.rawValue) ? "Access Denied" : "Unknown Error"
        
        println("error: \(errorType)")
        
        var alert =   UIAlertView.init(title:"Error Code:", message:errorType, delegate: self, cancelButtonTitle:"OK")
      
        alert.show()
    
        locMgr.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        println("DEBUG_______Came here for this callback delegate")
        if (status == CLAuthorizationStatus.Denied) {
            //location denied, handle accordingly
             println("01 - Came here for this callback delegate- clicked NO --")
            // stationTableView?.reloadData()
            locMgr.stopUpdatingLocation()
            var alert =   UIAlertView.init(title:"App Permission Denied:", message:"To re-enable, please go to Settings and turn on Location Service for this app.", delegate: self, cancelButtonTitle:"OK")
            
            alert.show()
        }
        else if (status == CLAuthorizationStatus.AuthorizedAlways) {
            //hooray! begin startTracking
             println("02- StatusAuthorizedAlways - this callback delegate")
            
            // self.getStationsJsonData()
            locMgr.startUpdatingLocation();
             self.calculateDistanceForData()
             stationTableView?.reloadData()
        } else if (status ==  CLAuthorizationStatus.AuthorizedWhenInUse) {
             println("03- StatusAuthorizedWhenInUse - this callback delegate")
            
          
            locMgr.startUpdatingLocation()
            self.calculateDistanceForData()
            stationTableView?.reloadData()
            
        }
        
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

