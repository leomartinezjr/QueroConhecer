//
//  PlaceAnnotation.swift
//  QueroConhecer
//
//  Created by Luana Martinez de La Flor on 06/10/21.
//

import Foundation
import MapKit


class placeAnnotation: NSObject, MKAnnotation {
    
    enum PlaceType {
        case place
        case poi
    }
    
    var coordinate: CLLocationCoordinate2D // uma lacalizacao obrigatorio
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var address: String?
    
    init(coordinate: CLLocationCoordinate2D, type: PlaceType) {
        self.coordinate = coordinate
        self.type = type
    }
    
    
    
}
