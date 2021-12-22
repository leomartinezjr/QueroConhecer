//
//  PlaceFindViewController.swift
//  QueroConhecer
//
//  Created by Luana Martinez de La Flor on 23/09/21.
//

import UIKit
import MapKit

protocol PlaceFinderDelegate: class { //cria um delegate , protocol
    func addPlace(_ place: Place)
}



class PlaceFindViewController: UIViewController {

    enum PlaceFinderMessageType{ // ira alimentar o showmassege
        case error(String)
        case confirmation(String)
    }
    
    
    @IBOutlet weak var tfcity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var AiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoad: UIView!
    
    var place: Place!
    weak var delegate: PlaceFinderDelegate? // delegate e obrigado a usar todos os metodos do placefinder
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))// implementa o clicar e segura
        gesture.minimumPressDuration = 2.0 // set quanto tempo o user tem q clicar na tela
        mapView.addGestureRecognizer(gesture) // linka o gesture com o map, no cado mapView nome que dei
        // Do any additional setup after loading the view.
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer ){
        if gesture.state == .began {// configura a pressao sera feita no caso no comeco
        load(show: true) // mostra a tela do load
            let point = gesture.location(in: mapView) //crieu um varial que pega o XY do no caso mapKit mas de view n map
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView) // converte XY de point em XY de mapViewa
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)// recupera o local onde foi clicado
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, erro) in // recupar se ha um local, tocando um map por serveidor Apple
                self.load(show: false) // termina o metod animascao 1
    //            guard let placemark = placemarks?.first else { return} // verifica se o placemark nao esta nulo
    //            print (Place.getFormattedAddress(whith: placemark)) // usa o plavemark nao nulo para alimentar o metodo Place da outra pag
                if erro == nil {
                    if !self.savePlace(whit: placemarks?.first) { // alimenta com o primeiro nome da LISTA
                        self.showMessage(type: .error("Nao foi lacalizado o lugar"))
                    }else{
                        self.showMessage(type: .error("ERROOO"))
                        }
                    }
                
            }
            
        }
    }
    
    @IBAction func findCity(_ sender: UIButton) {
        tfcity.resignFirstResponder() // comando para desaparecer teclado 1
        let city = tfcity.text! // recupera o texto que o usua digitou 2
        load(show: true) // chama o metodo da animcao e TRUE indica q quer a animaca 3
        let geoCode = CLGeocoder() // metodo para instanciar o recurso de maps do serve
        geoCode.geocodeAddressString( city) { (placemarks, erro) in // placemark /nome dado/ da uma LISTA dos luagares q o user buscou 4
            self.load(show: false) // termina o metod animascao 1
//            guard let placemark = placemarks?.first else { return} // verifica se o placemark nao esta nulo
//            print (Place.getFormattedAddress(whith: placemark)) // usa o plavemark nao nulo para alimentar o metodo Place da outra pag
            if erro == nil {
                if !self.savePlace(whit: placemarks?.first) { // alimenta com o primeiro nome da LISTA
                    self.showMessage(type: .error("Nao foi lacalizado o lugar"))
                }else{
                    self.showMessage(type: .error("ERROOO"))
                    }
                }
            }
        }
    
    func savePlace (whit placemark: CLPlacemark?) -> Bool{ // funca q devolver o end se for True
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {return false} // se tiver placemar e cordenada o cod continua
        
        let name = placemark.name ?? placemark.country ?? "Desconhecido" // se nao acha nome vai pais se n achar vai desconhecido
        let address = Place.getFormattedAddress(whith: placemark) // pega as cordenadas no endere=co ja, esqueleto criado no Place
        place = Place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, address: address) // alimenta o place com todos as info
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2500, longitudinalMeters: 2500) // center e a regiao q o use escolher latitute e longite quanto do map o user ira ver
        mapView.setRegion(region, animated: true) // mostra o mapa, atravez no map IBOUlet
        self.showMessage(type: .confirmation(place.name)) // chama o popUp e alimenra com o nome do lugar
        
        return true
    }
    
    func showMessage(type: PlaceFinderMessageType){ //fun que mostra o alert na tela do usuario
        let title: String, message: String //variaveis obrigada no popUp
        var hasConfirmation: Bool = false  // varial de confirmacao
        
        switch type { // switcho do enum a cima
        case .confirmation(let name): // pega uma string e alimenta o popUp
            title = "Local Encontrado"
            message = "Deseja Adicionar o \(name)"
            hasConfirmation = true
        case.error(let errorMessage):
            title = "ERROR"
            message = errorMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert) //icria a estrutura do alerta na tela o
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)// programa o botao cacel
        alert.addAction(cancelAction)// adiciona o bato no popUP
        if hasConfirmation{ // se positico
            let confirmAction = UIAlertAction(title: "OK", style: .default) { (action) in //programa o botao confirma
                self.delegate?.addPlace(self.place)//implemento o delegate delegou para outra classe salvar
                self.dismiss(animated: true, completion: nil)// fecha a tela
            }
            alert.addAction(confirmAction) // adiciona o botao confiurma no tela
        }
        
        present(alert, animated: true, completion: nil) // chama o alerta na tela
    }
    
    
    
    
    
    
    func load (show: Bool){
        viLoad.isHidden = !show // se esta escondido nao mostre 1
        if show {
            AiLoading.startAnimating() // esta ficar show(true) aparecer comece a animacao 2
        }else{
            AiLoading.stopAnimating()// caso contraio náo 3
        }
        
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil) // fechar tela
    }
    
    
    
}
