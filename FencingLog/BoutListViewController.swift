//
//  BoutListViewController.swift
//  FencingLog
//
//  Created by Samantha Herdman on 8/10/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import UIKit
import Firebase

class BoutListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var boutsArray = Array<Bout>()
    var fencerArray = Array<Fencer>()
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    let myFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myFormatter.dateFormat = "MM-dd-yyyy HH:mm"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boutsArray.removeAll()
        fencerArray.removeAll()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        
        ref = Database.database().reference()
        refHandle = ref.observe(DataEventType.value, with: { (snapshot) in

            // Get bout data
            let boutSnapshot = snapshot.childSnapshot(forPath: "bouts")
            let currentUser = Auth.auth().currentUser?.uid
            
            for child in boutSnapshot.children {
                if let bout = Bout(snapshot: child as! DataSnapshot) {
                    // Only show bouts the current user fenced in!
                    if bout.opponents.0 == currentUser || bout.opponents.1 == currentUser{
                        self.addOrUpdateBout(bout)
                    }
                }
            }
            
            // Get fencer data
            let fencerSnapshot = snapshot.childSnapshot(forPath: "fencers")
            
            for child in fencerSnapshot.children {
                if let fencer = Fencer(snapshot: child as! DataSnapshot) {
                    self.fencerArray.append(fencer)
                }
            }
            
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addOrUpdateBout(_ bout: Bout) {
        var boutSet = Set(boutsArray)
        
        for aBout in boutSet {
            if aBout.boutId == bout.boutId {
                boutSet.remove(aBout)
                boutsArray = Array(boutSet)
            }
        }

        boutsArray.append(bout)
    }
    
    func addOrUpdateFencer(_ fencer: Fencer) {
        var fencerSet = Set(fencerArray)
        
        for aFencer in fencerSet {
            if aFencer.fencerId == fencer.fencerId {
                fencerSet.remove(aFencer)
                fencerArray = Array(fencerSet)
            }
        }
        
        fencerArray.append(fencer)
    }
    
    @IBAction func addBout(_ sender: Any) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BoutViewController") as? BoutViewController else {
            print("Could not instantiate BoutViewController")
            return
        }
        
        vc.thisBout = nil
        vc.forEditing = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

// MARK: - UITableViewDelegate methods

extension BoutListViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Found \(self.boutsArray.count) bouts")
        return max(self.boutsArray.count, 1)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BoutViewController") as? BoutViewController else {
            print("Could not instantiate BoutViewController")
            return
        }
        
        vc.thisBout = boutsArray[indexPath.row]
        vc.isEditing = false
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

// MARK: - UITableViewDataSource methods

extension BoutListViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.row < self.boutsArray.count {
            let thisRecord = boutsArray[indexPath.row]
            configureBoutCell(bout: thisRecord, cell: cell)
        } else {
            if activityIndicator.isAnimating {
                cell.textLabel?.text = "Still looking for bouts..."
            } else {
                cell.textLabel?.text = "No bouts found."
            }
        }
        
        return cell

    }
    
    func configureBoutCell(bout: Bout, cell: UITableViewCell) {
            if let firstFencer = findFencer(bout.opponents.0),
                let secondFencer = findFencer(bout.opponents.1) {
        
                cell.textLabel?.text = "\(firstFencer.displayName()) (\(bout.scores.0)) vs. \(secondFencer.displayName()) (\(bout.scores.1))"
                if let date = bout.dateTime {
                    let boutDateString = myFormatter.string(from: date)
                    cell.detailTextLabel?.text = "\(bout.location!) \(boutDateString)"
                } else {
                    cell.detailTextLabel?.text = "the usual place"
                }
            } else {
                cell.textLabel?.text = "??"
        }
    }
    
    func findFencer(_ fencerId: String) -> Fencer?{
        
        for fencer in fencerArray {
            if fencer.fencerId == fencerId {
                return fencer
            }
        }
        return nil
    }
    
}
