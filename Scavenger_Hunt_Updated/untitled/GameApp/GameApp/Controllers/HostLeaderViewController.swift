//
//  GamePlayViewController.swift
//  GameApp
//
//  Created by Daniel Goldberg on 3/28/22.
//

import UIKit
import Firebase

class HostLeaderViewController: UIViewController , UITableViewDataSource, UITableViewDelegate
{
    
    @IBAction func cluesPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toClue", sender: nil)
    }
    @IBAction func leaderboardPressed(_ sender: UIButton) {
        
    }
    @IBAction func chatPressed(_ sender: UIButton) {
    }
    @IBOutlet weak var clueImage: UIImageView!
    @IBOutlet weak var leaderboardImage: UIImageView!
    @IBOutlet weak var chatImage: UIImageView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "leave2"){
            game = nil
    }
       
        if (segue.identifier == "toClue"){
            let destinationVC = segue.destination as!
                HostClueViewController
            destinationVC.game = self.game
           
            game.listner?.remove()
            game.clueListener?.remove()
            game.playersListener?.remove()
            game.yourPlayerListener?.remove()
            game = nil
        
        }
    }
    var game:gameInformation!
    var cellTapped:[Bool]! = []
    @IBOutlet weak var playerTable: UITableView!
    var playersRanked:[String]!
    
   
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage == clueImage{
            performSegue(withIdentifier: "toClue", sender: nil)        }
        
        else if tappedImage == chatImage{
            print("Chat!")
        }
        
        // Your action
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
        
      
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
           
        clueImage.isUserInteractionEnabled = true
        clueImage.addGestureRecognizer(tapGestureRecognizer2)
        leaderboardImage.isUserInteractionEnabled = true
        leaderboardImage.addGestureRecognizer(tapGestureRecognizer3)
        chatImage.isUserInteractionEnabled = true
        chatImage.addGestureRecognizer(tapGestureRecognizer4)
        playersRanked=Array(repeating: "", count: game.playerInfo.count)
        
      
        var count = 0
        
         for person in (self.game.playerInfo.sorted{ (first, second) -> Bool in
            if first.value["points"] != nil {
                if second.value["points"] != nil{
                return (first.value["points"] as! Int) >= (second.value["points"] as! Int)
                }
                else{
                    return true
                }
            }
            return false
          
         }){
            self.playersRanked[count] = person.key
           
            count=count+1

        }
       
        
      
        
    
        game.loadData {
            print("game refreshed")
        }
       
        
        game.loadPlayerData { [self] in
            playersRanked=Array(repeating: "", count: game.playerInfo.count)
            var count = 0
             for person in (self.game.playerInfo.sorted{ (first, second) -> Bool in
                if first.value["points"] != nil {
                    if second.value["points"] != nil{
                    return (first.value["points"] as! Int) >= (second.value["points"] as! Int)
                    }
                    else{
                        return true
                    }
                }
                return false
              
             }){
                self.playersRanked[count] = person.key
              
                count=count+1

            }
            playerTable.reloadData()
        }
      
        
//        clueTable.register(clueCell.self,
//                            forCellReuseIdentifier: "TableViewCell")
        playerTable.dataSource = self
        playerTable.delegate = self
        

    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.game.playerInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTable.dequeueReusableCell(withIdentifier: "playerCell",
            for: indexPath) as! playerCell

  
        if playersRanked[indexPath.row] == ""{
            cell.cluesSolvedLabel.text=""
            cell.nameLabel.text=""
            cell.rankLabel.text=""
            cell.pointLabel.text=""
        }
        else{
            
            cell.cluesSolvedLabel.text=String((self.game.playerInfo[ playersRanked[indexPath.row]]!["solveds"] as! String).split(separator: ",").count)+"/"+String(self.game.numClues)
            cell.nameLabel.text=playersRanked[indexPath.row]
            cell.rankLabel.text=String(indexPath.row+1)
            cell.pointLabel.text=String(self.game.playerInfo[ playersRanked[indexPath.row]]!["points"] as! Int) + " pts"
        }
        
        
        
        cell.nameLabel.adjustsFontSizeToFitWidth=true
        return cell

    }

    
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//
//            if  self.cellTapped[indexPath.row] == false{
//                self.cellTapped[indexPath.row] = true
//            }
//            else{
//                self.cellTapped[indexPath.row] = false
//
//            }
//
//            clueTable.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//
//    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 70
    }
    
    @IBAction func leaveGame(_ sender: UIButton) {
        let dialogMessage = UIAlertController(title: "Leave This Game?", message: "Are you sure you want to leave the game?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { [self] (action) -> Void in
            game.listner?.remove()
            game.clueListener?.remove()
            game.playersListener?.remove()
            game.yourPlayerListener?.remove()
            game.listner = nil
            game.clueListener = nil
            game.playersListener = nil
            game.yourPlayerListener = nil
            game.hostLeftGame(name: "")
            game = nil
            performSegue(withIdentifier: "leave2", sender: nil)
         })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(yes)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
//

    
}


