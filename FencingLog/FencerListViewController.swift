//
//  FencerListViewController.swift
//  FencingLog
//
//  Created by Samantha Herdman on 9/5/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import UIKit
import Firebase

protocol FencerSearchListDelegate {
    func assignOpponent(_ fencer: Fencer)
}

class FencerSearchListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate: FencerSearchListDelegate?
    let searchController = UISearchController(searchResultsController: nil)
    var currentOpponentId: String?
    var currentUserId: String?
    
    var fencerArray = Array<Fencer>()
    var filteredArray = Array<Fencer>()
    var placeHolderArray = Array<Fencer>()
    var placeHolderFilteredArray = Array<Fencer>()
    
    
    var ref: DatabaseReference!
    var refFencerHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserId = Auth.auth().currentUser?.uid
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchTableView.tableHeaderView = searchController.searchBar
        
        searchTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.activityIndicator.startAnimating()
        
        ref = Database.database().reference()
        refFencerHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            let fencerSnapshot = snapshot.childSnapshot(forPath: "fencers")
            
            for child in fencerSnapshot.children {
                if let fencer = Fencer(snapshot: child as! DataSnapshot) {
                    // You can't fence yourself!
                    if fencer.fencerId != self.currentUserId! {
                        if fencer.placeHolderOwner != nil {
                            self.placeHolderArray.append(fencer)
                        } else {
                            self.fencerArray.append(fencer)
                        }
                    }
                    print("Comparing: \(fencer.fencerId) with self: \(self.currentUserId!)")
                }
            }
            
            //self.activityIndicator.stopAnimating()
            self.searchTableView.reloadData()
            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        placeHolderFilteredArray.removeAll()
        filteredArray = fencerArray.filter({(fencer: Fencer) -> Bool in
            let isFirstMatch = fencer.firstName.lowercased().contains(searchText.lowercased())
            let isLastMatch = fencer.firstName.lowercased().contains(searchText.lowercased())
            if isFirstMatch || isLastMatch {
                if fencer.placeHolderOwner != nil {
                    placeHolderFilteredArray.append(fencer)
                    return false
                } else {
                    return true
                }
            }
            
            return false
        })
        

        searchTableView.reloadData()
    }

}

//MARK: - UISearchResults
extension FencerSearchListViewController {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: TableView deelgate methods
extension FencerSearchListViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredArray.count : fencerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FencerSearchCell", for: indexPath)
        
        let data = isFiltering() ? filteredArray : fencerArray
        
        if indexPath.row < data.count {
            let thisFencer = data[indexPath.row]
            
            cell.textLabel?.text = thisFencer.displayName()
            
            if let _ = thisFencer.placeHolderOwner {
                cell.detailTextLabel?.text = "(virtual opponent)"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var fencer: Fencer?
        
        let data = isFiltering() ? filteredArray : fencerArray
        
        if indexPath.row < data.count {
            fencer = data[indexPath.row]
            self.delegate?.assignOpponent(fencer!)
            let _ = self.navigationController?.popViewController(animated: true)
        }

    }
}
