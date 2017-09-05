//
//  BoutViewController.swift
//  FencingLog
//
//  Created by Samantha Herdman on 8/10/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator

class BoutViewController: UIViewController, UITextFieldDelegate, ValidationDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var weaponSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateTextButton: UIButton!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var opponentTextField: UITextField!
    @IBOutlet weak var scoreRightTextField: UITextField!
    @IBOutlet weak var scoreLeftTextField: UITextField!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var winnerSwitchControl: UISwitch!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var trayView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)

    let myFormatter = DateFormatter()
    let validator = Validator()
    
    var forEditing = false
    var saveEnabled = false
    var thisBout: Bout?
    
    var weapon: Weapon?
    var location: String?
    var opponentId: String?
    var score = (0,0)
    var isSelfWinner = false
    var notes = ""
    var boutDateTime: String?
    
    var fencerArray = Array<Fencer>()
    var ref: DatabaseReference!
    var refFencerHandle: DatabaseHandle!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        myFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        validator.registerField(locationTextField, rules: [RequiredRule()])
        validator.registerField(opponentTextField, rules: [RequiredRule()])
        validator.registerField(scoreRightTextField, rules: [RequiredRule()])
        validator.registerField(scoreLeftTextField, rules: [RequiredRule()])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        forEditing = thisBout == nil ? true : false
        configureFieldsForEditState()

        ref = Database.database().reference()
         refFencerHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            let fencerSnapshot = snapshot.childSnapshot(forPath: "fencers")
            
            for child in fencerSnapshot.children {
                if let fencer = Fencer(snapshot: child as! DataSnapshot) {
                    self.fencerArray.append(fencer)
                }
            }
            
            self.readValues()
            self.configureFieldsForEditState() 
            
         })
        


    }
    
    
    func readValues() {
        if let thisBout = thisBout {
            locationTextField?.text = thisBout.location
            dateTextButton.setTitle(myFormatter.string(from: thisBout.dateTime ?? Date()), for: UIControlState.normal)
            switch thisBout.weapon {
            case .epee:
                weaponSegmentedControl.selectedSegmentIndex = 0
            case .foil:
                weaponSegmentedControl.selectedSegmentIndex = 1
            case .saber:
                weaponSegmentedControl.selectedSegmentIndex = 2
            default:
                weaponSegmentedControl.selectedSegmentIndex = 3
            }
            
            let opponent = findFencer(thisBout.opponents.1)
            opponentTextField?.text = opponent!.firstName
            
            
            scoreLeftTextField?.text = String(describing: thisBout.scores.0)
            scoreRightTextField?.text = String(describing: thisBout.scores.1)
            
            winnerSwitchControl.setOn(thisBout.isSelfWinner, animated: true)
            
            winnerLabel.isHidden = false
            
            if thisBout.isSelfWinner == true {
                winnerLabel.text = "You won!"
            } else {
                winnerLabel.text = "They won!"
            }
            
            notesTextView?.text = thisBout.notes
            
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureFieldsForEditState() {
        locationTextField.isUserInteractionEnabled = forEditing
        dateTextButton.isUserInteractionEnabled = forEditing
        weaponSegmentedControl.isUserInteractionEnabled = forEditing
        opponentTextField.isUserInteractionEnabled = forEditing
        scoreLeftTextField.isUserInteractionEnabled = forEditing
        scoreRightTextField.isUserInteractionEnabled = forEditing
        winnerSwitchControl.isUserInteractionEnabled = forEditing
        notesTextView.isUserInteractionEnabled = forEditing
        
        locationTextField.isEnabled = forEditing
        weaponSegmentedControl.isEnabled = forEditing
        opponentTextField.isEnabled = forEditing
        scoreLeftTextField.isEnabled = forEditing
        scoreRightTextField.isEnabled = forEditing
        winnerSwitchControl.isEnabled = forEditing
        
        saveButton.isEnabled = saveEnabled
        saveButton.isHidden = !forEditing
        editButton.isHidden = forEditing
    }
    
    @IBAction func doEditBout(_ sender: Any) {
        self.forEditing = true
        configureFieldsForEditState()
    }
    
    @IBAction func doSaveBout(_ sender: Any) {
        validator.validate({(errors) in
            if errors.count > 0 {
                return
            }
        })
        
        activityIndicator.startAnimating()
        
        self.saveButton.isHidden = true
        
        if let dateString = boutDateTime {
            boutDateTime = myFormatter.string(from: myFormatter.date(from: dateString)!)
        } else {
            boutDateTime = myFormatter.string(from: Date())
        }
        
        switch weaponSegmentedControl.selectedSegmentIndex {
        case 0:
            weapon = .epee
        case 1:
            weapon = .foil
        case 2:
            weapon = .saber
        case 3:
            weapon = .smallsword
        case 4:
            weapon = .rapier
        default:
            weapon = .other
        }
        
        location = locationTextField.text
        
        
        if let opponentName = opponentTextField.text {
            let idArray = findFencerId(opponentName)
            
            if idArray.count > 0 {
                opponentId = idArray[0]
            } else {
                opponentId = "<unknown>"
            }
        } else {
            opponentId = "<unknown>"
        }
        
        if let right = Int(scoreRightTextField.text!), let left = Int(scoreLeftTextField.text!) {
            score = (Int(right), Int(left))
        }
        
        isSelfWinner = winnerSwitchControl.isOn
        
        notes = notesTextView.text
        
        let boutId = thisBout?.boutId ?? ref.child("bouts").childByAutoId().key
        
        let bout = ["boutId": boutId ,
                    "dateTime": boutDateTime ?? "01-01-1980 17:00",
                    "weapon": weapon?.rawValue ?? "epee",
                    "location": locationTextField?.text ?? "Someplace",
                    "opponents": [Auth.auth().currentUser?.uid, opponentId],
                    "scores": [score.0, score.1],
                    "isSelfWinner": isSelfWinner ? 1 : 0,
                    "notes": notesTextView?.text ?? "<no notes>"] as [String : Any]
        let childUdpates = ["/bouts/\(boutId)": bout]
        ref.updateChildValues(childUdpates)
                    
        self.activityIndicator.stopAnimating()
        
        self.editButton.isHidden = false
        self.forEditing = false
        saveEnabled = false
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
}


// MARK: Fencer methods
extension BoutViewController {
    func findFencerId(_ name: String) -> Array<String>{
        var idArray = Array<String>()
        
        for fencer in fencerArray {
            if fencer.firstName == name || fencer.lastName == name {
                idArray.append(fencer.fencerId)
            }
        }
        
        return idArray
    }
    
    func findFencer(_ id: String) -> Fencer?{
        for fencer in fencerArray {
            if fencer.fencerId == id  {
                return fencer
            }
        }
        
        return nil
    }
}



// MARK: - DatePicker methods
extension BoutViewController {
    @IBAction func didTapDate(_ sender: Any) {
        let showDatePicker = dateTimePicker.isHidden == true
        
        let transform = showDatePicker ? CGAffineTransform(translationX: 0, y: 195) : CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.25, animations: {
            self.trayView.transform = transform
            self.dateTimePicker.isHidden = !self.dateTimePicker.isHidden
        })
        
    }
    
    @IBAction func dateTimeDidChange(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: sender.date)
        if let boutDate = Calendar.current.date(from: components) {
            boutDateTime = myFormatter.string(from: boutDate)
            dateTextButton.setTitle(boutDateTime, for: UIControlState.normal)
        }
        
        saveEnabled = true
    }
}

// MARK: - UITextFieldDelegate methods
extension BoutViewController {
    @IBAction func textFieldDidEndEditing(_ textField: UITextField) {

    
        if let myScore = scoreRightTextField?.text, let theirScore = scoreLeftTextField?.text {
            if let mine = Int(myScore), let theirs = Int(theirScore) {
                // If scores are equal, the user needs to set this
                if mine == theirs {
                    winnerSwitchControl.isUserInteractionEnabled = true
                } else {
                // If the scores are unequal, we can determine the value programatically
                    winnerSwitchControl.isUserInteractionEnabled = false
                    
                    if mine > theirs {
                        winnerSwitchControl.setOn(true, animated: true)
                    } else {
                        winnerSwitchControl.setOn(false, animated: true)
                    }
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let _ = thisBout  {
            if forEditing == true {
                saveEnabled = true
                saveButton.isEnabled = true
            }
        }
        
        return true
    }
}

// MARK: - @IBActions
extension BoutViewController {
    
    @IBAction func changedData(_ sender: Any) {
        saveEnabled = true
        saveButton.isEnabled = true
    }
}

// MARK: - ValidationDelegate methods
extension BoutViewController {
    func validationSuccessful() {
        // good to go
        return
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        // errors found
        for error in errors {
            let field = error.0 as! UITextField
            field.layer.borderWidth = 0.0
        }
    }
}

//MARK: - UISearchResults
extension BoutViewController {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

