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
        print("joinedScreenSegue")

        if segue.identifier == "toGame"{
        let destinationVC = segue.destination as!
            GamePlayViewController
            destinationVC.game = game
            game.listner?.remove()
            game.listner=nil
            game = nil
            destinationVC.name = name
           
        }}
    @IBOutlet weak var chaneNameButton: UIButton!
    @IBOutlet weak var joinCodeLabel: UILabel!
    var game:gameInformation!
    var joinedWhileStarted:Bool!
    @IBOutlet weak var spinny: UIActivityIndicatorView!
    var name = ""
    @IBOutlet weak var waitingForHostLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var textNameChange: UITextField!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var hostedBy: UILabel!
    @IBOutlet weak var playersNum: UILabel!
    let acceptableChar = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_()[]|/\\:;,><.-+=@$&*"
    @IBOutlet weak var cluesNum: UILabel!
    @IBOutlet weak var screenNames: UITextView!
    let db = Firestore.firestore()
    @IBAction func enterGame(_ sender: UIButton) {
        performSegue(withIdentifier: "toGame", sender: nil)
    }
    @IBOutlet weak var enterGameLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        textNameChange.autocorrectionType = .no
        
        if joinedWhileStarted==true{
            waitingForHostLabel.text="Game In Progress"
            enterGameLabel.setTitle("Enter Game", for: .normal)
            waitingForHostLabel.numberOfLines=1
            Utilities.styleFilledButton(enterGameLabel)
        }
       else{
            waitingForHostLabel.text="Waiting For Host To Start Game"
        
       
        enterGameLabel.isHidden=true
       }
        self.joinCodeLabel.text=self.game.joinCode
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray

        errorLabel.text = ""
        errorLabel.textColor = UIColor.red
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        

        game.loadData { [self] in
            self.gameName.text = self.game.gameName
            self.gameName.adjustsFontSizeToFitWidth=true
            self.desc.text = self.game.gameDesc
            
            self.hostedBy.text = self.game.host
            self.cluesNum.text =  String(self.game.numClues) + " Clues"
           let playerString = self.game.players.joined(separator: "    ")
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attributedString = NSMutableAttributedString.init(string: playerString,attributes: [.paragraphStyle: paragraph,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20)])
            var count = 0
            let values=[UIColor.red,UIColor.blue, UIColor.green, UIColor.purple, UIColor.black , UIColor.cyan]
            for player in self.game.players{
                let range = (playerString as NSString).range(of: player)
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: values[count%values.count], range: range)
                count=count+1
            }
           
            
            self.screenNames.attributedText=attributedString
//            self.screenNames.text = self.game.players.joined(separator: "    ")
            self.playersNum.text = String(self.game.numPlayers) + " Players"
            if self.joinedWhileStarted == false && self.game.gameState==true{
                performSegue(withIdentifier: "toGame", sender: nil)
            }
            print("joinedLoadData")
        }
        self.textNameChange.placeholder = name
    }
    @IBAction func valueChanged(_ sender: UITextField) {
        if sender.text?.last != nil{
            
            if (!(acceptableChar.contains((sender.text?.last)!)) || sender.text!.count > 20){
                textNameChange.text = String(sender.text?.dropLast() ?? "")
            }
            else{
                textNameChange.text = sender.text!
            }
            textNameChange.text!.removeAll { !(acceptableChar.contains($0)) }
            textNameChange.text=String(textNameChange.text!.prefix(20))
        }
        
    }
    
    @IBAction func changePressed(_ sender: UIButton) {
        spinny.startAnimating()
        if (textNameChange.text != nil ){
            if !(game.players.contains(where: {$0.caseInsensitiveCompare(textNameChange.text!) == .orderedSame})) || (name.lowercased() == textNameChange.text!.lowercased() && name != textNameChange.text!){
                errorLabel.textColor = UIColor.green
                errorLabel.text = "Name Changed!"
                game.replacePlayers(existingPlayer: name, player: textNameChange.text!)
                name=textNameChange.text!
                textNameChange.placeholder = name

                textNameChange.text=""

              
        }
            else{
                errorLabel.textColor = UIColor.red

                errorLabel.text="Name Already Taken"
                textNameChange.text=""
            }

    }
        dismissKeyboard()

        
        spinny.stopAnimating()

    }
    @IBAction func leaveGame(_ sender: UIButton) {
        game.listner?.remove()
        game.listner=nil
        self.game.leftGame(name: self.name)
        game = nil
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
}


