//
//  FencerProfileViewController.swift
//  FencingLog
//
//  Created by Samantha Herdman on 9/6/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator


class FencerProfileViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var clubNameTextField: UITextField!
    @IBOutlet weak var primaryLocationTextField: UITextField!
    @IBOutlet weak var rightHandedSwitch: UISwitch!
    @IBOutlet weak var epeeSwitch: UISwitch!
    @IBOutlet weak var foilSwitch: UISwitch!
    @IBOutlet weak var saberSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    let validator = Validator()
    
    var fencer: Fencer?
    
    var email: String!
    var firstName: String?
    var lastName: String?
    var clubName: String?
    var location: String?
    var rightHanded = true
    var weapons = [String]()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validator.registerField(firstNameTextField, rules: [RequiredRule()])
        validator.registerField(lastNameTextField, rules: [RequiredRule()])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref = Database.database().reference()
        
        if let fencer = fencer {
            userNameLabel?.text = fencer.fencerId
            firstNameTextField?.text = fencer.firstName
            lastNameTextField?.text = fencer.lastName
            clubNameTextField?.text = fencer.club
            primaryLocationTextField?.text = fencer.primaryLocation
            rightHandedSwitch.isOn = fencer.rightHanded == true
            epeeSwitch.isOn = fencer.weapons.contains(Weapon(rawValue: Weapon.epee.rawValue)!)
            foilSwitch.isOn = fencer.weapons.contains(Weapon(rawValue: Weapon.foil.rawValue)!)
            saberSwitch.isOn = fencer.weapons.contains(Weapon(rawValue: Weapon.saber.rawValue)!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doSaveProfile(_ sender: Any) {
        validator.validate({(errors) in
            if errors.count > 0 {
                return
            }
        })
    
        // start activity indicator here
    
        saveButton.isEnabled = false
        let fencerId = Auth.auth().currentUser?.uid
        firstName = firstNameTextField?.text
        lastName = lastNameTextField?.text
        clubName = clubNameTextField?.text
        location = primaryLocationTextField?.text
        rightHanded = rightHandedSwitch.isOn
        
        if epeeSwitch.isOn {
            weapons.append(Weapon.epee.rawValue)
        }
        
        if foilSwitch.isOn {
            weapons.append(Weapon.foil.rawValue)
        }
        
        if saberSwitch.isOn {
            weapons.append(Weapon.saber.rawValue)
        }
        
        if let fencerId = fencerId {
            let fencerData = ["userId": fencerId,
                              "email": email,
                              "firstName": firstName!,
                              "lastName": lastName!,
                              "club": clubName ?? "",
                              "primaryLocation": location ?? "",
                              "rightHanded": rightHanded,
                              "weapons": weapons] as [String : Any]
            
            let childUpdates = ["/fencers/\(fencerId)": fencerData]
            ref.updateChildValues(childUpdates)
        }
        
        // stop animating here
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - ValidationDelegate methods
extension FencerProfileViewController {
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

