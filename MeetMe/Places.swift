//
//  Places.swift
//  MeetMe
//
//  Created by Bruno Cortes on 03/02/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import MapKit
import UIKit

class Places: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: MKPlacemark
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: MKPlacemark) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
