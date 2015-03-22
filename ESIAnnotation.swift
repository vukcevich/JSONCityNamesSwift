//
//  ESIAnnotation.swift
// 
//
//  Created by Marijan Vukcevich on 3/12/15.
//  Copyright (c) 2015 East Side Interactive, LLC by Marijan Vukcevich. All rights reserved.
//


import Foundation
import MapKit

class ESIAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}