//
//  Bout.swift
//  FencingLog
//
//  Created by Samantha Herdman on 8/10/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import Foundation
import Firebase

class Bout: NSObject {
    
    var boutId: String?
    var dateTime: Date?
    var weapon: Weapon
    var location: String?
    var opponents: (String, String)
    var scores: (Int, Int)
    var isSelfWinner: Bool
    var notes: String?
    
    let formatter = DateFormatter()
    

    init(boutId: String, dateTime: Date, weapon: Weapon, location: String, opponents: (String, String), scores: (Int, Int), isSelfWinner: Bool, notes: String) {
        self.boutId = boutId
        self.dateTime = dateTime
        self.weapon = weapon
        self.location = location
        self.opponents = opponents
        self.scores = scores
        self.isSelfWinner = isSelfWinner
        self.notes = notes
    }
    
    init?(snapshot: DataSnapshot) {
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        guard let boutId = dict["boutId"] as? String else { return nil }
        guard let dateTime = dict["dateTime"] as? String else { return nil }
        guard let weapon = dict["weapon"] as? String else { return nil }
        guard let location = dict["location"] as? String else { return nil }
        guard let opponents = dict["opponents"] as? Array<String> else { return nil }
        guard let scores = dict["scores"] as? Array<Int> else { return nil }
        guard let isSelfWinner = dict["isSelfWinner"] as? Int else { return nil }
        //guard let notes = dict["notes"] as? String else { return nil }
        
        let notes = dict["notes"] as? String ?? " "
        
        self.boutId = boutId
        self.dateTime = formatter.date(from: dateTime)
        self.weapon = Weapon(rawValue: weapon)!
        self.location = location
        self.opponents = (opponents[0], opponents[1])
        self.scores = (scores[0], scores[1])
        self.isSelfWinner = isSelfWinner > 0 ? true : false
        self.notes = notes
    }
}
