//
//  PlacesTableViewController.swift
//  QueroConhecer
//
//  Created by Luana Martinez de La Flor on 23/09/21.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    var places: [Place] = [] // lista dos lugares a ser guardado
    let ud = UserDefaults.standard
    var lbNoPlace: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        
        lbNoPlace = UILabel()
        lbNoPlace.text = "Cadastre os locais que deseja conhecer \n clicando no botao mais acima"
        lbNoPlace.textAlignment = .center
        lbNoPlace.numberOfLines = 0 // todas as carctericas do da view
            }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! != "mapSegue"{ //assegura que as informacoes vao para a view certa
            let vc = segue.destination as! PlaceFindViewController
            vc.delegate = self
        }else{
            let vc = segue.destination as! MapViewController // recupera a view controller e passa info para map View
            switch sender { // ao clicar na cell no didDeclectwrow o user seleciona a cell, ai que recupero o sender
                case let place as Place:
                    vc.places = [place] //caso consiga recupera 1(um) place, ele manda essa informacao
                default:
                    vc.places = places // caso contrario ele manda todas a info
            }
        }
    }
    
    
    
    func loadPlaces(){// funcao para carregar os dados salvos
        if let placeData = ud.data(forKey: "places"){
            do{
                places = try JSONDecoder().decode([Place].self, from: placeData) //tenta decodificar em um array a entrada
                tableView.reloadData()//recarrega dos dados mais para dados on line
            }catch{
                print(error.localizedDescription)//captura o codigop do erro 
            }
        }
        
    }
    
    func savePlaces(){
        let json = try? JSONEncoder().encode(places) //encoda meu dados em json
        ud.set(json, forKey: "places") // salva os dados na CHAVE "places"
        
    }
    
    @objc func showAll(){
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
  
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // é a tabela das cidades, ou o listado
        if places.count > 0 { // titulo a cima da tabelview
            let btShowAll = UIBarButtonItem(title: "Mostrar todos no Mapa", style: .plain, target: self, action: #selector(showAll)) //se tiver mais de um lugar inplementa o botao e chama a func show
            navigationItem.leftBarButtonItem = btShowAll
            tableView.backgroundView = nil
        }else{
            navigationItem.leftBarButtonItem = nil // se nao tive na aparece o botao
            tableView.backgroundView = lbNoPlace // se náo tever nada aparece o label de informacao
        }
        
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // configura a cell da tableview
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // seleciona uma cell e ao clicar manda para a proxima tela 
        let place = places[indexPath.row] // seleciona a celular na table view
        performSegue(withIdentifier: "mapSegue", sender: place) // manda para o asegue map
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { // confiuugra o delete ouarrastar p o lado e deletar !
        if editingStyle == .delete{ // pode ser outra coisa no no caso é um delete
            places.remove(at: indexPath.row) //selecioa oq sera ser deletado
            tableView.deleteRows(at: [indexPath], with: .fade) // aqui deleta o objeto
            savePlaces() //salva novmanete agora o sem o objeto
        }
    }
    
    
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    

}

//aqui o delagate que implementei na outra view ira fazer a percistencia dos dados. resumo: criei um protocolo na outra view com um metodo,
// creiei uma variavel com a instancia dessa classe e implemente essa variavel no meu codigo, q obrigatoriamente tem q essa func
// aqui criei essa extescao com a instancia desse protocolo e é aqui que farei a persistencia dos dados 

extension PlacesTableViewController: PlaceFinderDelegate{
    func addPlace(_ place: Place) {
        if !places.contains(place){ // so foi possivel pq sis sabe oq tem que comprar com equatable, se n contem (!)
            places.append(place) // adicona a array places
            tableView.reloadData()// recarrega a lista para ja mostra o elemento
            savePlaces() // ira fazer a persistencia de dados
            
        }
    }
    
    
    
}
