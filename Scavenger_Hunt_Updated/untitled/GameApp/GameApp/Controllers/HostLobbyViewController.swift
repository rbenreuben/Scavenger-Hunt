//
//  JoinedScreenViewController.swift
//  GameApp
//
//  Created by Daniel Goldberg on 3/21/22.
//

import UIKit
import Firebase
class HostLobbyViewController: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("joinedScreenSegue")

        if segue.identifier == "toHostClue"{
        let destinationVC = segue.destination as!
            HostClueViewController
            self.game.listner?.remove()
            destinationVC.game = game
            self.game = nil
        }}
    @IBOutlet weak var chaneNameButton: UIButton!
    @IBOutlet weak var joinCodeLabel: UILabel!
    var game:gameInformation!
    var joinCode:String!
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
        performSegue(withIdentifier: "toHostClue", sender: nil)
    }
    @IBOutlet weak var enterGameLabel: UIButton!
    @IBOutlet weak var joinCodeLabelBig: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        textNameChange.autocorrectionType = .no
        
        
        Utilities.styleFilledButton(enterGameLabel)

        self.joinCodeLabel.text=joinCode
        self.joinCodeLabelBig.text = "Join Code: "+joinCode
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
        errorLabel.text = ""
        errorLabel.textColor = UIColor.red
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        

        game.loadData { [self] in
            self.gameName.text = game.gameName
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
            if game.numPlayers == 0{
                self.screenNames.attributedText =  NSMutableAttributedString.init(string: "")
                self.screenNames.text="Waiting for Players..."
            }
            else{
                self.screenNames.text=""
                self.screenNames.attributedText=attributedString
            }
           
            
            self.playersNum.text = String(self.game.numPlayers) + " Players"
           
            print("joinedLoadData")
        }
        self.textNameChange.placeholder = game.host
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
           
                errorLabel.textColor = UIColor.green
                errorLabel.text = "Your Host Name Was Changed!"
            db.collection("currentGames").document(joinCode).updateData(["host":textNameChange.text!])
                name=textNameChange.text!
                textNameChange.placeholder = name
                textNameChange.text=""

        
           

    }
        dismissKeyboard()

        
        spinny.stopAnimating()
        
    }
    @IBAction func startGame(_ sender: UIButton) {
        db.collection("currentGames").document(joinCode).updateData(["started":true])
        performSegue(withIdentifier: "toHostClue", sender: nil)
    }
    @IBAction func leaveGame(_ sender: UIButton) {
        game.listner?.remove()
        game.listner=nil
        self.game.hostLeftGame(name: self.name)
        game = nil
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
}


