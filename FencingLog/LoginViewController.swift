//
//  LoginViewController.swift
//  FencingLog
//
//  Created by Samantha Herdman on 8/10/17.
//  Copyright © 2017 Samantha J. Herdman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftValidator

class LoginViewController: UIViewController, UITextFieldDelegate {
   
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let validator = Validator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.delegate = self
        userPassword.delegate = self
        
        validator.registerField(userName, errorLabel: nameErrorLabel, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        
        validator.registerField(userPassword, errorLabel: passwordErrorLabel, rules: [RequiredRule(), MinLengthRule(length: 5)])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doLogin(_ sender: Any) {
        activityIndicator.startAnimating()
        
        if let userName = userName.text, let userPassword = userPassword.text {
            Auth.auth().signIn(withEmail: userName, password: userPassword) { (user, error) in
                self.activityIndicator.stopAnimating()
            
                if error != nil {
                    let alert = UIAlertController(title: "Sorry...", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        // OK button tapped
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                //self.addDefaultData()
                
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BoutListViewController") as? BoutListViewController else {
                    print("Could not instantiate BoutListViewController")
                    return
                }
            
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    @IBAction func doRegister(_ sender: Any) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController else {
            print("Could not instantiate CreateAccountViewController")
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func doRecoverPassword(_ sender: Any) {
        
    }
    
    func addDefaultData() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let samUid = "ciRsxU6v97WgokvMmEI9WmaNkOB2"
        let danUid = "VHPUBsYJmxRPfHLWTPGLDcO0KT23"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        let key = ref.child("bouts").childByAutoId().key
        let bout = [ "boutId" : key,
                     "datetime" : dateFormatter.string(from: Date()),
                     "weapon" : "epee",
                     "location" : "Academie Lafayette",
                     "opponents" : [samUid, danUid],
                     "scores": [4, 5],
                     "isSelfWinner" : 0] as [String : Any]
        
        let childUpdates = ["bouts/\(key)" : bout]
        ref.updateChildValues(childUpdates)
    }
    
}

// MARK: - UITextFieldDelegate methods
extension LoginViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        validator.validateField(textField, callback: { (error) in
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1.0
            
            if let error = error {
                error.errorLabel?.text = error.errorMessage // works if you added labels
                error.errorLabel?.isHidden = false
            } else {
                textField.layer.borderWidth = 0.0
            }
        })
    }
}
