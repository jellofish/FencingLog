//
//  Fencer.swift
//  FencingLog
//
//  Created by Samantha Herdman on 8/10/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import Foundation
import Firebase


class Fencer: NSObject {
    
    var fencerId: String
    var firstName: String
    var lastName: String
    var email: String
    var dateOfBirth: Date?
    var rightHanded: Bool
    var weapons: Array<Weapon>
    var club: String?
    var primaryLocation: String?
    
    let formatter = DateFormatter()
    
    init(fencerId: String, firstName: String, lastName: String, email: String, dateOfBirth: Date, rightHanded: Bool, weapons: Array<Weapon>, club: String, primaryLocation: String) {
        self.fencerId = fencerId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.rightHanded = rightHanded
        self.weapons = weapons
        self.club = club
        self.primaryLocation = primaryLocation
    }
    
    init?(snapshot: DataSnapshot) {
        formatter.dateFormat = "MM-dd-yyyy HH:MM"
        
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        
        guard let fencerId = dict["userId"] as? String else { return nil }
        guard let firstName = dict["firstName"] as? String else { return nil }
        guard let lastName = dict["lastName"] as? String else { return nil }
        guard let email = dict["email"] as? String else { return nil }
        guard let weapons = dict["weapons"] as? Array<String>else { return nil }
        
        self.fencerId = fencerId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        
        self.weapons = Array<Weapon>()
        for sword in weapons {
            switch sword {
            case "epee":
                self.weapons.append(Weapon.epee)
            case "foil":
                self.weapons.append(Weapon.foil)
            case "saber":
                self.weapons.append(Weapon.saber)
            default:
                self.weapons.append(Weapon.other)
            }
        }
        
        // Optional data
        self.club = dict["club"] as? String
        self.primaryLocation = dict["primaryLocation"] as? String
        
        if let rightHanded = dict["rightHanded"] as? String {
            self.rightHanded = Bool(rightHanded)!
        } else {
            self.rightHanded = true
        }
        
        if let dateOfBirth = dict["dateOfBirth"] as? String {
            self.dateOfBirth = formatter.date(from: dateOfBirth)!
        } else {
            self.dateOfBirth = nil
        }
    }
}
