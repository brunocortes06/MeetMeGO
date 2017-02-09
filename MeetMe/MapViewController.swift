//
//  MapViewController.swift
//  MeetMe
//
//  Created by Bruno Cortes on 30/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var resultsController: ResultsController?
    var lat:Double?
    var long:Double?
    let locationManager = CLLocationManager()
    var selectedPin: MKPlacemark?
    var tipoEncontro:String?
    var impressionar:Bool?
    var day:Bool?
    
    let map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print((tipoEncontro)!, (impressionar)! ,(day)!)
        
        self.map.delegate = self
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(backToQuestions))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Outro Lugar?", style: .plain, target: self, action: #selector(searchAgain))

        view.addSubview(map)
        
        setInputsContainerView()
        
        getUserLocation()
        
    }
    
    func backToQuestions() {
        let questionController = QuestionController()
        questionController.mapViewController = self
        let navController = UINavigationController(rootViewController: questionController)
        present(navController, animated: true, completion: nil)
    }
    
    func searchAgain() {
        map.removeAnnotations(map.annotations)
        searchForPlaces()
    }
    
    func setInputsContainerView(){
        map.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        map.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        map.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        map.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func getUserLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
//        let span = MKCoordinateSpanMake(0.15, 0.15)
//        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        let searchRadius: CLLocationDistance = 10000
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, searchRadius * 2.0, searchRadius * 2.0)
        
        map.setRegion(region, animated: true)
        
        searchForPlaces()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alertcontroller = UIAlertController(title: "Erro", message: "Falha ao determinar localização!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertcontroller.addAction(defaultAction)
        self.present(alertcontroller, animated: true, completion: nil)
        self.viewDidLoad()
    }
    
    func searchForPlaces() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = getRandomPlace()
        request.region = map.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                return
            }
            
            for item in response.mapItems {
                self.dropPinZoomIn(item.placemark)
            }
        }
    }
    
    func getRandomPlace() ->String{
        var array = [String]()
        if self.tipoEncontro == tipoEncontroEnum.divertido.rawValue {
            if self.day == true {
                array = ["Parque Ibirapuera", "Parque Villa Lobos", "Parque", "Roller Jam", "Avenida Paulista", "Reserva Cultural", "CERET", "Parque Ecológico do Tietê", "Parque da Aclimação", "Urban Motion Parque de Trampolins", "Casa de Pedra", "Altitude Park", "Trilhas de SP", "Praça Roosevelt"]
            } else {
                array = ["Comedians", "Espaço SP Diversoes", "Urban Motion Parque de Trampolins", "Aeromagic Balloons", "Speedland", "Villa Bowling", "Beverly Hills", "Altitude Park"]
            }
            if self.impressionar == true {
                array = ["Escape 60", "Fugativa", "Puzzle Room", "IFLY", "Escape Club", "60 minutos", "Escape Time", "Escape Hotel", "Jockey Club", "Convento Warzone Airsoft"]
            }
        } else if self.tipoEncontro == tipoEncontroEnum.amoroso.rawValue {
            if self.day == true {
                array = ["Motel","Praça Pôr do Sol"]
            } else {
                array = ["Motel", "Praça Pôr do Sol"]
            }
        } else if self.tipoEncontro == tipoEncontroEnum.batePapo.rawValue {
            if self.day == true {
                array = ["Praça por do sol", "Terraço do MAC", "CCSP", "CCBB", "Jardins do Ipiranga", "Parque Jardim da Luz", "Pinacoteca", "Parque do Carmo", "Jardim Botânico", "Mercadão", "Pedra Grande"]
            } else {
                array = ["Augusta", "Veloso Bar", "Bar do Juarez", "gracia bar", "Noname Boteco", "Bar de Cima", "Mirante 9 de Julho"]
            }
        } else if self.tipoEncontro == tipoEncontroEnum.comida.rawValue {
            if self.day == true {
                array = ["Paris 6", "Outback", "La Pergoletta", "Voloso Bar"]
            } else {
                array = ["Paris 6", "Nahoe Sushi", "Mori Sushi", "Bravo Bistro"]
            }
            if self.impressionar == true {
                array = ["Terraço Itália","Era uma vez um chalezinho", "Skye Bar e Restaurante"]
            }
        }
        
//        let array = ["Outback", "Cinema", "Veloso Bar", "Villa Mix", "Motel"]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        print(array[randomIndex])
        return array[randomIndex]
    }
    
    func getDirections(){
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){

        // cache the pin esta errado, preciso fazer o metodo de pin selected p setar isso direito**********************************************
        selectedPin = placemark
        // clear existing pins
//                map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        map.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        map.setRegion(region, animated: true)
    }
    
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
        button.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
}

enum tipoEncontroEnum: String {
    case batePapo = "bate papo descontraído"
    case comida = "almoço/jantar romântico"
    case divertido = "encontro divertido"
    case amoroso = "encontro amoroso"
}
