//
//  PickUpsTableViewController.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 11/13/16.
//  Copyright © 2016 Lusenii Kromah. All rights reserved.
//

import UIKit
import Firebase
class PickUpsTableViewController: UITableViewController {

    var pickUps:[PickUp] = []
    var firebaseRef: FIRDatabaseReference!
    @IBOutlet var emptyPickpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStorage()
        configureDatabase()
    }
    
    @IBAction func addFlightButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add A friend's flight", message: "Receive notificaitons on your friends flight", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            let url = firstTextField.text!
            
            self.getFlightInfo(url)
       
    
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Your Friend's Flight Link"
        }
   
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func errorMessage(){
        
        
        let alert = UIAlertController(title: "Flight Error", message:"No flight data was found" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func addPickUpFlight(pickUp:PickUp){
        
    
        
        let user = FIRAuth.auth()?.currentUser
        guard let uid = user?.uid else {
            
            return
        }
        
        let reference = firebaseRef.database.reference().child("users").child(uid).child("pickups").childByAutoId()
        
        
         pickUp.pickupID = reference.key
        let dictionary = pickUp.toDictionary()
        
        reference.setValue(dictionary){ (error, ref) -> Void in
            if error != nil {
                print("\(error)")
            }
        }
        
        
        pickUps.append(pickUp)
        
        
        OperationQueue.main.addOperation{
            self.tableView.reloadData()
        }
    
    }
    
    func getFlightInfo(_ url: String) {
        let request = URLRequest(url: URL(string: url)! as URL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                self.errorMessage()
                print(error)
                return
            }
            
            // Parse JSON data
            if let data = data {
                
                self.parseJSONData(data)
                
            }
            
        })
        
        task.resume()
    }
    
    func parseJSONData(_ data: Data)  {
        
        
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            
           
            
            let pickUp = PickUp()
            
            pickUp.arrivalAirport = jsonResult?["arrivalAirportFsCode"] as! String!
            pickUp.arrivalTime = jsonResult?["arrivalTime"] as! String!
            pickUp.arrivalDate = jsonResult?["arrivalMonthDayYear"] as! String!
            pickUp.arrivalGate = jsonResult?["arrivalGate"] as! String!
            pickUp.arrivalTerminal = jsonResult?["arrivalTerminal"] as! String!
            pickUp.passengerName = jsonResult?["passenger"] as! String!
           
            
            self.addPickUpFlight(pickUp: pickUp)
            
        } catch {
            print(error)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if pickUps.count == 0 {
            tableView.backgroundView = emptyPickpView
            tableView.separatorColor = .white
            return pickUps.count
        }
        
        tableView.backgroundView = nil
        return pickUps.count
 
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickUpCell", for: indexPath) as! PickUpViewCell
        
        let pickup = pickUps[indexPath.row]
        
        cell.friendsName?.text = pickup.passengerName!
        cell.arrivalFlightLabel?.text = pickup.arrivalAirport!
        cell.arrivalTerminalLabel?.text = "Termial \(pickup.arrivalTerminal!)"
        cell.arrivalGateLabel?.text = "Gate \(pickup.arrivalGate!)"
        cell.arivalFlightTimeLabel?.text = pickup.arrivalDate

      

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

          tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Delete button
        let deleteAction = UITableViewRowAction(style:
            UITableViewRowActionStyle.default, title: "Delete",handler: { (action,
                indexPath) -> Void in
                // Delete the row from the data source
                let pickup = self.pickUps[indexPath.row]
                
                self.deleteFromFirebase(pickup:pickup)
                
                
                self.pickUps.remove(at: indexPath.row)
                
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
        })
        
        return [deleteAction]
    }
    
    
    func configureStorage() {
        firebaseRef = FIRDatabase.database().reference()
    }
    
    func configureDatabase() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            return
        }
        
        let child:FIRDatabaseReference = firebaseRef.child("users").child(uid).child("pickups")
        
        child.observe(.childAdded
        ) { (snapshot:FIRDataSnapshot) in
            
            if let pickupDictionary = snapshot.value as? [String : Any]  {
                
                let pickup = PickUp()
                pickup.setValuesForKeys(pickupDictionary)
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }

        }
        
    }
    
    func deleteFromFirebase(pickup:PickUp){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            return
        }
        
        let user = firebaseRef.database.reference().child("users").child(uid)
        
        if let pickupID = pickup.value(forKey: "pickupID") as? String {
            
            _ = user.child("pickups").child(pickupID).removeValue { (error, ref) in
                if error != nil {
                    print("error \(error)")
                }
            }
        }
    }
}
