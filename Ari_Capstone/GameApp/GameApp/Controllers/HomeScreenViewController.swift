//
//  HomeScreenViewController.swift
//  GameApp
//
//  Created by Daniel Garcia on 2/17/22.
//

import UIKit
import FirebaseAuth
import Firebase

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var UserN: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let Uname = Auth.auth().currentUser?.email else { return }
        UserN.text = Uname
        
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    /* https://medium.com/@dominicfholmes/generating-qr-codes-in-swift-4-b5dacc75727c
     */
 
    @IBOutlet weak var clue: UITextField!
    @IBOutlet weak var qrCode: UIImageView!
    
    @IBAction func generateQR(_ sender: Any) {
        if let myString = clue.text {
            let data = myString.data(using: String.Encoding.ascii)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            
            let img = UIImage(ciImage: (filter?.outputImage)!)
            
            qrCode.image = img
            
            let db = Firestore.firestore()
            
            db.collection("pracCurrentGames").document().collection("clues").document("clue1")
                        .setData([
                        "description":myString,
                        "howManySolves":"0",
                        "name":"clue one!"]){
                            Err in
                            if let oErr = Err {
                                print("Error: \(oErr)")
                            }
                            else {
                                print("document added")
                            }
                        }
        
        }
    }
    
    
    @IBAction func printQR(_ sender: UIButton) {
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .general
        printInfo.jobName = "My Print Job"
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = qrCode.image
        printController.present(animated: true, completionHandler: nil)
    }
    
    
}
