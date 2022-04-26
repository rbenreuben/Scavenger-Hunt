//
//  JoinCodeViewController.swift
//  GameApp
//
//  Created by Daniel Goldberg on 3/9/22.
//

import Foundation
import UIKit
import Firebase

class JoinCodeViewController: UIViewController {
    
    var NAME = ""
    var game:gameInformation!
    var db:Firestore! =  Firestore.firestore()

    var joiningWhileStarted:Bool=false
    @IBOutlet weak var spiny: UIActivityIndicatorView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("joinCodeSegue")
        if (segue.identifier == "toJoinScreen"){
            
        let destinationVC = segue.destination as! JoinedScreenViewController
        destinationVC.game =  game
            game = nil
            destinationVC.name = NAME
            destinationVC.joinedWhileStarted=self.joiningWhileStarted
    }
      
    }
    @IBOutlet weak var errorMessage: UILabel!
    
    @IBOutlet weak var joinCodeValue: UITextField!
    var acceptableChar = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessage.text = ""
        spiny.style = .medium
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
        print(navigationController.viewControllers)

    }
    
   
    @IBAction func editingChangedJoinCode(_ sender: UITextField) {
        if (sender.text?.last != nil){
            if (!(acceptableChar.contains((sender.text?.last)!) ) || sender.text!.count > 4){
                joinCodeValue.text = String(sender.text?.dropLast() ?? "")
            }
            else{
                joinCodeValue.text = joinCodeValue.text?.uppercased()
            }
            joinCodeValue.text!.removeAll { !(acceptableChar.contains($0)) }
            joinCodeValue.text=String(joinCodeValue.text!.prefix(4))
        }
            
    }
    
    
    @IBOutlet weak var joinButton: UIButton!
    
    @IBAction func joinPressed(_ sender: Any) {
        spiny.startAnimating()
        if (joinCodeValue.text != nil ){
            if(joinCodeValue.text!.count < 4) {
                self.errorMessage.text = "Join Code must be 4 digits long"
                spiny.stopAnimating()
                }
        
            else{
                let docRef = db.collection("currentGames").document(joinCodeValue.text!)
                docRef.getDocument {  (document, error )    in
                    if let document = document, document.exists {
                        let gameInfo = document.data()
                        let game = gameInformation(game: gameInfo!)
                        if game.numPlayers < game.maxPlayers || game.maxPlayers == -1{
                            if game.gameState==false{
                                self.joiningWhileStarted=false
                            }
                            else{
                                self.joiningWhileStarted=true
                            }
                            while true{
                                self.NAME = "scavenger_"+String(Int.random(in: 1..<10000))
                                if (game.players.contains(self.NAME)){
                                }
                                else{
                                    break
                                }
                            }
                        game.updatePlayers(player: self.NAME)
                        self.game=game
                            self.performSegue(withIdentifier: "toJoinScreen", sender: self)
                            
                        }
                        else{
                            self.errorMessage.text="Max Players In Game"
                        }
    //                    }
                    }
                    else{
                                      self.errorMessage.text="Join Code Not Found"

                    }
                    self.spiny.stopAnimating()

                }
                }
        }

    }
        

    }
    



