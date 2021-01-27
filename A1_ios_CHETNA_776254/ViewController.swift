//
//  ViewController.swift
//  A1_ios_CHETNA_776254
//
//  Created by MacbookPro on 2021-01-25.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeBtn: UIButton!
    @IBOutlet weak var overlayBtn: UIButton!
    
    // @IBOutlet weak var mapView: MKMapView!
    //@IBOutlet weak var routeBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var locationArray = [CLLocationCoordinate2D]()
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        addTap()
    }
    func addTap()
    {
        let tap = UITapGestureRecognizer(target: self , action: #selector(dropPin))
        tap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tap)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations[0]

        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude

        displayLocation(latitude: latitude, longitude: longitude, title: "User Location", subtitle: "")
    }
    
   // MARK: - display user location method
     
     func displayLocation (latitude: CLLocationDegrees,
                           longitude: CLLocationDegrees,
                           title: String,
                           subtitle:String)
     {
         let latDelta: CLLocationDegrees = 0.05
         let lngDelta: CLLocationDegrees = 0.05

         let span = MKCoordinateSpan (latitudeDelta: latDelta, longitudeDelta: lngDelta)
         let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

         let region = MKCoordinateRegion(center: location, span: span)
         mapView.setRegion(region, animated: true)

         let annotation = MKPointAnnotation()
         annotation.title = title
         annotation.subtitle = subtitle
         annotation.coordinate = location
         mapView.addAnnotation(annotation)
     }
    @objc func dropPin(sender: UITapGestureRecognizer)
    {
        if locationArray.count == 3
        {
            removePin()
            locationArray.removeAll()
            mapView.removeOverlays(mapView.overlays)
        }
        let touchpoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchpoint, toCoordinateFrom: mapView)
        self.locationArray.append(coordinate)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Point"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
                
    }

    @IBAction func viewOverlay(_ sender: Any)
    {
        addPolygon()
    }
    @IBAction func viewRoute(_ sender: Any)
    {
        let loc1 = locationArray[0]
        let loc2 = locationArray[1]
        let loc3 = locationArray[2]

        Route(from: loc1, to: loc2)
        Route(from: loc2, to: loc3)
        Route(from: loc3, to: loc1)
    }
    func  Route(from : CLLocationCoordinate2D, to : CLLocationCoordinate2D)
    {
            mapView.removeOverlays(mapView.overlays)
            let fromPlaceMark = MKPlacemark(coordinate: from, addressDictionary: nil)
            let toPlaceMark = MKPlacemark(coordinate: to, addressDictionary: nil)
        
            let fromMapItem = MKMapItem(placemark: fromPlaceMark)
            let toMapItem = MKMapItem(placemark: toPlaceMark)

            let directionRequest = MKDirections.Request()
            directionRequest.source = fromMapItem
            directionRequest.destination = toMapItem
            directionRequest.transportType = .automobile
            
            let direction = MKDirections(request: directionRequest)
            
            direction.calculate { (response, error) in
                guard let response = response else {
                    if let error = error {
                        print("ERROR FOUND : \(error.localizedDescription)")
                    }
                    return
                }
                
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                let rect = route.polyline.boundingMapRect
               self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                
            }
        }
    
    //MARK: - polygon  meyhod
    func addPolygon()
    {
                   let Point1 = locationArray[0]
                   let Point2 = locationArray[1]
                   let Point3 = locationArray[2]

        var coordinateInput:[CLLocationCoordinate2D]=[Point1,Point2,Point3]
        let polygon = MKPolygon(coordinates: &coordinateInput, count: coordinateInput.count)
        mapView.addOverlay(polygon)
    }
    
        
    //MARK: - remove pin from the map
    func removePin()
    {
        for annotation in mapView.annotations
        {
            mapView.removeAnnotation(annotation)
        }
    }
}
extension ViewController : MKMapViewDelegate
    {
        //MARK: - view for annotation method
    
        func mapView(_ mapView: MKMapView, viewFor annotaion : MKAnnotation) -> MKAnnotationView?
        {
            if annotaion is MKUserLocation
            {
                return nil
            }
            let pinAnnotation = MKPinAnnotationView(annotation: annotaion, reuseIdentifier: "droppablePin")
           pinAnnotation.animatesDrop = true
            pinAnnotation.pinTintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            return pinAnnotation

        }
    
        //MARK: - render for overlay func
    
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKCircle
            {
                let rendrer = MKCircleRenderer(overlay: overlay)
                rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
                rendrer.strokeColor = UIColor.green
                rendrer.lineWidth = 2
                return rendrer
            }
            else if overlay is MKPolyline
            {
                let rendrer = MKPolylineRenderer(overlay: overlay)
                rendrer.strokeColor = UIColor.blue
                rendrer.lineWidth = 3
                return rendrer
            }
            else if overlay is MKPolygon
            {
                let rendrer = MKPolygonRenderer(overlay: overlay)
                rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
                rendrer.strokeColor = UIColor.green
                rendrer.lineWidth = 4
                return rendrer
            }
            return MKOverlayRenderer()
        }
}
