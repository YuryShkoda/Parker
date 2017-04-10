//
//  PointsListTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Yuri Shkoda on 3/12/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class SpotsListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var locationManager = CLLocationManager()
    
    var spots = [CLLocationCoordinate2D]()
    
    @IBAction func reportPoint(_ sender: Any) {
        
        if userLocation.longitude != 0 && userLocation.latitude != 0 {
        
            let locationToSave = PFObject(className: "ParkingSpots")
            
            locationToSave["isAvailable"] = true
            locationToSave["location"]    = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
            locationToSave["addedBy"]     = PFUser.current()?.username
            
            
            let acl = PFACL()
            
            acl.getPublicReadAccess  = true
            acl.getPublicWriteAccess = true
            
            locationToSave.acl = acl
            
            locationToSave.saveInBackground(block: { (success, error) in
                
                if error == nil {
                
                    print("New spot saved.")
                
                } else {
                
                    print(error)
                
                }
                
            })
        
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showParkingSpot" {
        
            if let destination = segue.destination as? SpotViewController {
            
                if let row = tableView.indexPathForSelectedRow?.row {
                
                    destination.spot = spots[row]
                    
                    let query = PFQuery(className: "ParkingSpots")
                    
                    query.whereKey("location", equalTo: PFGeoPoint(latitude: spots[row].latitude, longitude: spots[row].longitude))
                    
                    query.findObjectsInBackground(block: { (objects, error) in
                        
                        if let parkingSpots = objects {
                        
                            for parkingSpot in parkingSpots {
                            
                                parkingSpot["isAvailable"] = false
                                
                                parkingSpot.saveInBackground()
                            
                            }
                        
                        }
                        
                    })
                
                }
            
            }
        
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
        
            userLocation = location
            
            let query = PFQuery(className: "ParkingSpots")
            
            query.whereKey("isAvailable", equalTo: true)
            
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
                
            query.limit = 10
                
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let parkingSpots = objects {
                
                    self.spots.removeAll()
                    
                    for parkingSpot in parkingSpots {
                    
                        self.spots.append(CLLocationCoordinate2D(latitude: (parkingSpot["location"] as AnyObject).latitude, longitude: (parkingSpot["location"] as AnyObject).longitude))
                    
                    }
                
                }
                
            })
            
            self.tableView.reloadData()
        
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return spots.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let spotLocation = CLLocation(latitude: spots[indexPath.row].latitude, longitude: spots[indexPath.row].longitude)
        
        let distance = userCLLocation.distance(from: spotLocation) / 1609
        
        let roundedDistance = round(distance * 100) / 100
        
        cell.textLabel?.text = String(roundedDistance) + " miles"

        return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
