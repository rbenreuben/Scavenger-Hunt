//
//  LoginViewController.swift
//  GameApp
//
//  Created by Daniel Garcia on 2/17/22.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Pword: UITextField!
    
    @IBOutlet weak var Login: UIButton!
    @IBOutlet weak var Error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements() {
        Error.alpha = 0
        
        Utilities.styleTextField(Email)
        Utilities.styleTextField(Pword)
        Utilities.styleFilledButton(Login)
    }
    
    @IBAction func LoginTapped(_ sender: UIButton) {
        let email = Email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = Pword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result,error) in
            
            if error != nil {
                self.Error.text = error!.localizedDescription
                self.Error.alpha = 1
            }
            else {
                let HVC = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeVC) as? HomeScreenViewController
                
                self.view.window?.rootViewController = HVC
                self.view.window?.makeKeyAndVisible()
            }
        }
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
