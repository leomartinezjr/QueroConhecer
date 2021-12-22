//
//  Place.swift
//  QueroConhecer
//
//  Created by Luana Martinez de La Flor on 24/09/21.
//

import Foundation
import  MapKit


struct Place: Codable {
    
    let name: String
    let latitude: CLLocationDegrees //variavel q
    let longitude: CLLocationDegrees
    let address: String
    
    
    
    var coordinate:CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) // um modo mais simples de agrupar as duas cordenadas
    }
    
    static func getFormattedAddress(whith placemark: CLPlacemark) -> String { //pega as cordenadas do MAP e transforma em String pelo oq o user digita
        var address = " "
        
        if let street = placemark.thoroughfare{
            address += street // se tiver, recupera RUA
        }
        if let number = placemark.subThoroughfare{
            address += "\(number)" // se tiver, recupera NUMERO
        }
        if let subLocality = placemark.subLocality{
            address += "\(subLocality)" // se tive, recupera BAIRRO
        }
        if let city = placemark.subLocality {
            address += "\n \(city)" // se tiver, recupera a CIDADE
        }
        if let state = placemark.administrativeArea{
            address += " - \(state)" // se tiver, recupera o ESTADO
        }
        if let postalCode = placemark.postalCode{
            address += " \n CEP: \(postalCode)" // se tiver, recupera o CEP
        }
        if let country = placemark.country{
            address += "\n \(country)" // PAIS
        }
        return address
    }
}


extension Place: Equatable {// equatable  é uma "guia" para no caso compracao de places
    static func == (lhs: Place, rhs: Place) -> Bool{ //compora dos places para saber se sáo iguais
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude //retorna TRUE se forem iguais
    }
    
}
