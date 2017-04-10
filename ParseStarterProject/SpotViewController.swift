//
//  SpotViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Yuri Shkoda on 3/15/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class SpotViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func backToSpotsList(_ sender: Any) {
    
        let query = PFQuery(className: "ParkingSpots")
        
        query.whereKey("location", equalTo: PFGeoPoint(latitude: spot.latitude, longitude: spot.longitude))
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if let parkingSpots = objects {
            
                for parkingSpot in parkingSpots {
                
                    parkingSpot["isAvailable"] = true
                    
                    parkingSpot.saveInBackground()
                
                }
            
            }
            
        })
        
        performSegue(withIdentifier: "backToSpotsList", sender: self)
    
    }
    
    @IBAction func routeMe(_ sender: Any) {
        
        let routeToCLLocation = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        
        CLGeocoder().reverseGeocodeLocation(routeToCLLocation) { (placemarks, error) in
            
            if let placemarks = placemarks {
            
                if placemarks.count > 0 {
                
                    let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                    
                    let mapItem = MKMapItem(placemark: mKPlacemark)
                    
                    mapItem.name = "Parking Spot"
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    
                    mapItem.openInMaps(launchOptions: launchOptions)
                
                }
            
            }
            
        }
        
        let query = PFQuery(className: "ParkingSpots")
        
        query.whereKey("location", equalTo: PFGeoPoint(latitude: spot.latitude, longitude: spot.longitude))
        
        query.findObjectsInBackground { (objects, error) in
            
            if let parkingSpots = objects {
            
                for parkingSpot in parkingSpots {
                
                    parkingSpot.deleteInBackground()
                
                }
                
            }
            
        }
        
    }
    
    var spot = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: spot, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = spot
        
        annotation.title = "Parking Spot"
        
        map.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
