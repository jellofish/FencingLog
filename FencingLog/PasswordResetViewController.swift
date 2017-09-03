//
//  PasswordResetViewController.swift
//  FencingLog
//
//  Created by Samantha Herdman on 8/31/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PasswordResetViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doReset(_ sender: Any) {
        if let email = emailTextField.text {
            activityIndicator.startAnimating()
            label.text = "Sending password reset request..."
            
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.label.text = "There was a problem."
                    
                    let alert = UIAlertController(title: "Sorry...", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        // OK button tapped
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.label.text = "Password reset request sent."
                    
                    let alert = UIAlertController(title: "Request Sent", message: "Please check your email!", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        // OK button tapped
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
}
