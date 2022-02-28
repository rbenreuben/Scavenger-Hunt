//
//  SignUpViewController.swift
//  GameApp
//
//  Created by Daniel Garcia on 2/17/22.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var FName: UITextField!
    @IBOutlet weak var LName: UITextField!
    @IBOutlet weak var UName: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var PWord: UITextField!
    
    @IBOutlet weak var SignUp: UIButton!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        ErrorLabel.alpha = 0
        
        Utilities.styleTextField(FName)
        Utilities.styleTextField(LName)
        Utilities.styleTextField(UName)
        Utilities.styleTextField(Email)
        Utilities.styleTextField(PWord)
        Utilities.styleFilledButton(SignUp)
        
    }
    
    func validateInputs() -> String? {
        if FName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            LName.text?.trimmingCharacters(in:
            .whitespacesAndNewlines) == "" ||
            UName.text?.trimmingCharacters(in:
            .whitespacesAndNewlines) == "" ||
            Email.text?.trimmingCharacters(in:
            .whitespacesAndNewlines) == "" ||
            PWord.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        
        let cleanedPW = PWord.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cleanedE = Email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isEmailValid(cleanedE) == false {
            return "Email: Please make sure you enter a valid email."
        }
        
        if Utilities.isPasswordValid(cleanedPW) == false {
            return "Password: Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    
    
    @IBAction func SignUpTapped(_ sender: UIButton) {
        
        let error = validateInputs()
        
        if error != nil {
            showError(error!)
        }
        else {
            let FirstName = FName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let LastName = LName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let UserName = UName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let Email = Email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let Password = PWord.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            Auth.auth().createUser(withEmail: Email, password: Password) { (result,err) in
                if err != nil {
                    self.showError("Error creating user")
                }
                else {
                    
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstname": FirstName, "lastname": LastName,"username": UserName, "uid": result!.user.uid]) { (error) in
                        
                        if error != nil {
                            self.showError("Error saving user data")
                        }
                    }
                    self.transitionToHome()
                }
            }
        }
    }
    
    func showError(_ message: String){
        ErrorLabel.text = message
        ErrorLabel.alpha = 1
    }
    
    func transitionToHome(){
        
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeVC) as? HomeScreenViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
