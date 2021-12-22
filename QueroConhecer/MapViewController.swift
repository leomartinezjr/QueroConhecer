//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Luana Martinez de La Flor on 24/09/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    enum MapMessageType{
        case routeError
        case authorizationWarning
        
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var loadingQ: UIActivityIndicatorView!
    
    var places: [Place]! // aqui que ira guarda a lista de places que sera passado do Plaseviewcontroller
    var poi:[MKAnnotation] = []
    lazy var lacationManager = CLLocationManager() // LAZY se estancia quando for utilizar
    var btUserLacation: MKUserTrackingButton! // n estanciado mas com as caracteristicas
    var selectAnotation: placeAnnotation! // varivel q irar quardar um p,ace annotion
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        mapView.mapType = .hybrid
        viInfo.isHidden = true
        mapView.delegate = self // implementa o delegate do mapview ou seja delaga a criacao da cell para outra func no caso nossa anntion personalizada
        lacationManager.delegate = self
        
        if places.count == 1 {
            title = places[0].name
        }else{
            title = "Meus lugares"
        }
        
        
        for place in places { // para casa item(place) na minha lista de places
            addToMap(place) // func de adionar no map,
            lbName.text = place.name
        }
        
        configureLacationButton()
        showPlaces()
        requestUserLocationAuthorization()

    }
    
    func configureLacationButton(){
        btUserLacation = MKUserTrackingButton(mapView: mapView)
        btUserLacation.backgroundColor = .white
        btUserLacation.frame.origin.x = 10
        btUserLacation.frame.origin.y = 10
        btUserLacation.layer.cornerRadius = 5
        btUserLacation.layer.borderWidth = 1
        btUserLacation.layer.borderColor = UIColor(named: "Main")?.cgColor
    }
    
    
    func requestUserLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled(){ //esse servico tiver ativado segue
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    mapView.addSubview(btUserLacation)
               
                case .denied:
                    showMessage(type: .authorizationWarning)
                case .notDetermined:
                    lacationManager.requestWhenInUseAuthorization()
                case .restricted:
                    break
            }
        }else{
            //nao da
        }
        
    }
    
    

    // ******* Ex de fazer uma place annotation default do sistema com pin vermelho, annotation é os ponto do map
//    func addToMap(_ place: Place)  { // uma func q recebe um place
//        let annotation = MKPointAnnotation() // estancia
//        annotation.coordinate = place.coordinate // estrai as corrdenadas do place a receber
//        annotation.title = place.name  // seta o nome no place
//        mapView.addAnnotation(annotation) // agora adiciona o lugar no mapa
//    }
  
    // ******** Ex de uma anotation personalizada
    
    func addToMap(_ place: Place)  { // uma func q recebe um place
        let annotation = placeAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name  // seta o nome no place
        annotation.address = place.address
        mapView.addAnnotation(annotation) // agora adiciona o lugar no mapa,
    }
    
    
    
    
    
    
    func showPlaces(){
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    func showInfo(){ // metodo que reabilita a barra de informacao abaixo e popula os os nomes
        lbName.text = selectAnotation.title
        lbAddress.text = selectAnotation.address
        viInfo.isHidden = false
        
        
    }
    
    
    

    @IBAction func showRoute(_ sender: UIButton) {
    }
    
    @IBAction func showSearchBAr(_ sender: Any) {
        searchBar.resignFirstResponder()// esconde o teclado
        searchBar.isHidden = !searchBar.isHidden // desse jeito o button esconde e mostra a barra
    }
    
    
    func showMessage(type: MapMessageType){ //fun que mostra o alert na tela do usuario

        let title = type == .authorizationWarning ? "Aviso" : "ERRO" // variavel mutavel
        let message = type == .authorizationWarning ? "Para usar os recursos de localizacao vc precisa permitir" : "Nao foi possivel encontrar essa rota"


        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert) //icria a estrutura do alerta na tela o
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)// programa o botao cacel
        alert.addAction(cancelAction)// adiciona o bato no popUP
        if type == .authorizationWarning{
            let confirmAction = UIAlertAction(title: "Ir para Ajustes", style: .default) { (action) in //programa o botao confirma
                if let appSettings = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(confirmAction) // adiciona o botao confiurma no tela
        }

        present(alert, animated: true, completion: nil) // chama o alerta na tela
    }
}

extension MapViewController: MKMapViewDelegate{ // da acesso ao serie de metodos do map view
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { // metodo usado para modificar uma annotatioview
        
        if !(annotation is placeAnnotation){ // casa n seja um placeanntion volta nil, isso para eviatr confundir com o pin do use
            return nil
        }
        
        let type = (annotation as! placeAnnotation).type // estou tratando o annotion da func como se fosse a minha annotion personalizada no caso a type
        let indentifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: indentifier) as? MKMarkerAnnotationView // cria annottation reusavel e estrai daqui casa ja exista
        if annotationView == nil{ // porem comeca nulo temos criar a prieira celular
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: indentifier)
        }
        
        annotationView?.annotation = annotation //aqui esta reconstruindo a placeannotion com dados novos
        annotationView?.canShowCallout = true // seta uma balao
        annotationView?.markerTintColor = type == .place ? UIColor(named: "Main") : UIColor(named: "poi") // seta a cor
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph" ) : UIImage(named: "poiGlyph")// seta a image
        annotationView?.displayPriority = type == .place ? .required : .defaultLow // mostra por prioridade
        
        
        return annotationView
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) { // implementa clicar na localizacao
        selectAnotation = (view.annotation as! placeAnnotation)
        showInfo()
    }
}


// fiz po delegate do seach bar ser da tela (aquele metodo de arrastar ate o quadrado da view) depois por extensáo implemetei o delaget do searchbar
extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loadingQ.startAnimating()// barrinha do loadin
        
        let request = MKLocalSearch.Request() // manda uma requesicao para o servers da apple
        request.naturalLanguageQuery = searchBar.text // "traduz oq user quer" ex procura cafe apafrece cafeterias
        request.region = mapView.region // set qual regiao ira pesquisar no caso usa a propiedade do mapview regian
        let search = MKLocalSearch(request: request) // constroi a requiscao
        search.start { (response, error) in
            if error == nil {
                guard let response = response else {
                    self.loadingQ.stopAnimating()
                    return }
                
                self.mapView.removeAnnotations(self.poi) // o mapView(mapinha) ira apagar todos annotation do poi
                self.poi.removeAll()//  ira limpr todos as anootion da lista poi
                for item in response.mapItems{ // for para recuperar os dados pesquisas, para casa item do arroy q a Apple mandou
                    let annotation = placeAnnotation(coordinate: item.placemark.coordinate , type: .poi)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormattedAddress(whith: item.placemark)
                    self.poi.append(annotation) // aqui adiciona o item buscado na array de poi
                }
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true) //mostra pontos cadastrano num ponto, mas nesse caso s[o chama os poi
                
                
            }
            self.loadingQ.stopAnimating()
        }
        
    }
    
    
}


extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLacation)
            lacationManager.startUpdatingHeading()// faz atualizacao do usuario e infroma isso
        default:
            break
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }

}

