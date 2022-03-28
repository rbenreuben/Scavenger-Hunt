//
//  JoinedScreenViewController.swift
//  GameApp
//
//  Created by Daniel Goldberg on 3/21/22.
//

import UIKit
import Firebase
class JoinedScreenViewController: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let destinationVC = segue.destination as!
            GamePlayViewController
            destinationVC.game = game
            destinationVC.name = name
    
    }
    @IBOutlet weak var chaneNameButton: UIButton!
    var game:gameInformation!
    @IBOutlet weak var spinny: UIActivityIndicatorView!
    var name = ""
    var changes = 0
    var gameState:Bool = false {
        didSet{
            if changes > 0{
                performSegue(withIdentifier: "toGame", sender: self)
            }
            else{
                changes = changes + 1
            }
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var textNameChange: UITextField!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var hostedBy: UILabel!
    @IBOutlet weak var playersNum: UILabel!
    @IBOutlet weak var cluesNum: UILabel!
    @IBOutlet weak var screenNames: UITextView!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        game.loadData {
            self.errorLabel.text = ""
            self.gameName.text = self.game.gameName
            self.desc.text = self.game.gameDesc
            self.hostedBy.text = self.game.host
            self.cluesNum.text = "# of Clues: "+String(self.game.numClues)
            self.screenNames.text = self.game.players.joined(separator: "  ")
            self.playersNum.text = "# of Players: " + String(self.game.numPlayers)
            self.gameState = self.game.gameState
            
        }
        self.textNameChange.placeholder = name
    }
    @IBAction func valueChanged(_ sender: UITextField) {
        if textNameChange.text != nil{
            let acceptableChar = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_?!@#$%^&*()\\{}[];|`~+<>:'/.,"
            if (!(acceptableChar.contains((sender.text!.last)!) ) || sender.text!.count > 20){
                textNameChange.text = String(textNameChange.text!.dropLast() )
            }
            
        }
    }
    
    @IBAction func changePressed(_ sender: UIButton) {
        spinny.startAnimating()
        if (textNameChange.text != nil ){
            print(textNameChange.text!)
            if !(game.players.contains(where: {$0.caseInsensitiveCompare(textNameChange.text!) == .orderedSame})){
                game.replacePlayers(existingPlayer: name, player: textNameChange.text!)
                name=textNameChange.text!
                textNameChange.placeholder = name
                textNameChange.text=""

        }
            else{
                errorLabel.text="Name Already Taken"
                textNameChange.text=""
                
            }
            spinny.stopAnimating()
    }
    }
    @IBAction func leaveGame(_ sender: UIButton) {
        self.game.leftGame(name: self.name)
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


