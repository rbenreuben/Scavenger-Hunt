//
//  HomeScreenViewController.swift
//  GameApp
//
//  Created by Daniel Garcia on 2/17/22.
//

import UIKit
import FirebaseAuth

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var UserN: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let Uname = Auth.auth().currentUser?.usern else { return }
        UserN.text = Uname
        
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
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
