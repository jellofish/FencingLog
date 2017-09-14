//
//  CreateAccountViewController.swift
//  FencingLog
//
//  Created by Samantha Herdman on 8/10/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.delegate = self
        userPassword.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doRegister(_ sender: Any) {
        activityIndicator.startAnimating()
        
        if let userName = userName.text, let userPassword = userPassword.text {
            Auth.auth().createUser(withEmail: userName, password: userPassword) { (user, error) in
            
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    let alert = UIAlertController(title: "Sorry...", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        // OK button tapped
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FencerProfileViewController") as? FencerProfileViewController else {
                        print("Could not instantiate FencerProfileViewController")
                        return
                    }
                    
                    vc.email = userName
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - UITextFiedlDelegate methods
extension CreateAccountViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.userName {
            // validate?
        } else if textField == self.userPassword {
            // validate?
        } else {
            // Not handled
        }
    }
}
