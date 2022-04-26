//
//  GamePlayViewController.swift
//  GameApp
//
//  Created by Daniel Goldberg on 3/28/22.
//

import UIKit
import Firebase

class playerCell: UITableViewCell{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var cluesSolvedLabel: UILabel!
}
//
//extension UITableView {
//    func isCellVisible(section:Int, row: Int) -> Bool {
//        guard let indexes = self.indexPathsForVisibleRows else {
//            return false
//        }
//        return indexes.contains {$0.section == section && $0.row == row }
//    }
//}



class LeaderBoardViewController: UIViewController , UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var ScanButton: UIButton!
    @IBAction func scanPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toScanner2", sender: nil)
    }
    @IBAction func cluesPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toClue", sender: nil)
    }
    @IBAction func leaderboardPressed(_ sender: UIButton) {
        
    }
    @IBAction func chatPressed(_ sender: UIButton) {
    }
    @IBOutlet weak var scanImage: UIImageView!
    @IBOutlet weak var clueImage: UIImageView!
    @IBOutlet weak var leaderboardImage: UIImageView!
    @IBOutlet weak var chatImage: UIImageView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "leaveGame2"){
            game = nil
    }
        if (segue.identifier == "toScanner2"){
            let destinationVC = segue.destination as!
                QRCodeScannerViewController
            
            
            destinationVC.game = self.game
            destinationVC.myName = self.name
            game.listner?.remove()
            game.clueListener?.remove()
            game.playersListener?.remove()
            game.yourPlayerListener?.remove()
            game = nil
        
        }
        if (segue.identifier == "toClue"){
            let destinationVC = segue.destination as!
                GamePlayViewController
            destinationVC.game = self.game
            destinationVC.name = self.name
            game.listner?.remove()
            game.clueListener?.remove()
            game.playersListener?.remove()
            game.yourPlayerListener?.remove()
            game = nil
        
        }
    }
    var game:gameInformation!
    var name:String!
    var myRankVisible:Bool=false
    var cellTapped:[Bool]! = []
    @IBOutlet weak var playerTable: UITableView!
    var playersRanked:[String]!
    var myRank:Int!
    
    @IBOutlet weak var personalRank: UILabel!
    @IBOutlet weak var persoanlName: UILabel!
    @IBOutlet weak var personalProgress: UILabel!
    @IBOutlet weak var personalPoints: UILabel!
    
    @IBOutlet weak var personalRankTop: UILabel!
    @IBOutlet weak var personalNameTop: UILabel!
    @IBOutlet weak var personalPointsTop: UILabel!
    @IBOutlet weak var personalProgressTop: UILabel!
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage == clueImage{
            performSegue(withIdentifier: "toClue", sender: nil)        }
        else if tappedImage == scanImage{
            performSegue(withIdentifier: "toScaner2", sender: nil)        }
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
        print(navigationController.viewControllers)
        self.myRank=1
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            scanImage.isUserInteractionEnabled = true
            scanImage.addGestureRecognizer(tapGestureRecognizer)
        clueImage.isUserInteractionEnabled = true
        clueImage.addGestureRecognizer(tapGestureRecognizer2)
        leaderboardImage.isUserInteractionEnabled = true
        leaderboardImage.addGestureRecognizer(tapGestureRecognizer3)
        chatImage.isUserInteractionEnabled = true
        chatImage.addGestureRecognizer(tapGestureRecognizer4)
        playersRanked=Array(repeating: "", count: game.playerInfo.count)
        
        self.persoanlName.adjustsFontSizeToFitWidth = true
        self.personalNameTop.adjustsFontSizeToFitWidth=true
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
            if person.key == self.name{
               
                self.myRank = count+1
         }
            count=count+1

        }
       
        
            self.personalNameTop.text=""
            self.personalPointsTop.text=""
            self.personalRankTop.text=""
            self.personalProgressTop.text=""
            self.persoanlName.text=""
            self.personalPoints.text=""
            self.personalRank.text=""
            self.personalProgress.text=""
        
    
        game.loadData {
            print("game refreshed")
        }
       
        game.loadYourPlayerData(player: self.name!){
            if self.game.myInfo != nil{
            print("your player refresh")
            
            self.personalPoints.text = String(self.game.myInfo["points"] as! Int) + " pts"
                self.personalProgress.text = String((self.game.myInfo["solveds"] as! String).split(separator: ",").count )+"/"+String(self.game.numClues)
            }
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
                if person.key == self.name{
                   
                    self.myRank = count+1
             }
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
            if indexPath.row == self.myRank-1{
                cell.nameLabel.textColor=UIColor(red: 66/255, green: 184/255, blue: 1.0, alpha: 1.0)
                self.myRankVisible = true
            }
            else{
                cell.nameLabel.textColor=UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            }
            cell.cluesSolvedLabel.text=String((self.game.playerInfo[ playersRanked[indexPath.row]]!["solveds"] as! String).split(separator: ",").count)+"/"+String(self.game.numClues)
            cell.nameLabel.text=playersRanked[indexPath.row]
            cell.rankLabel.text=String(indexPath.row+1)
            cell.pointLabel.text=String(self.game.playerInfo[ playersRanked[indexPath.row]]!["points"] as! Int) + " pts"
            
            print(cell.nameLabel)
            print(cell.cluesSolvedLabel.text)
            print(cell.rankLabel)
            print(cell.pointLabel.text)
            
            for player in self.playersRanked{
                print(player)
            }
            
        }
        
        if  self.myRankVisible == true{
            self.persoanlName.text=""
            self.personalPoints.text=""
            self.personalRank.text=""
            self.personalProgress.text=""
            self.personalNameTop.text=""
            self.personalPointsTop.text=""
            self.personalRankTop.text=""
            self.personalProgressTop.text=""

        }
        else if indexPath.row + 1 < self.myRank {
            self.personalNameTop.text=""
            self.personalPointsTop.text=""
            self.personalRankTop.text=""
            self.personalProgressTop.text=""
            self.persoanlName.text=self.name
            self.personalPoints.text=String(game.myInfo["points"] as! Int)
            self.personalRank.text=String(self.myRank)
            self.personalProgress.text=String((self.game.myInfo["solveds"] as! String).split(separator: ",").count)  + "/" + String(self.game.numClues)

        }
        else if indexPath.row + 1 >= myRank  {

            self.persoanlName.text=""
            self.personalPoints.text=""
            self.personalRank.text=""
            self.personalProgress.text=""
            self.personalNameTop.text=self.name
            self.personalPointsTop.text=String(game.myInfo["points"] as! Int)+" pts"
            self.personalRankTop.text=String(self.myRank)
            self.personalProgressTop.text=String((self.game.myInfo["solveds"] as! String).split(separator: ",").count)  + "/" + String(self.game.numClues)

        }
        
        cell.nameLabel.adjustsFontSizeToFitWidth=true
        return cell

    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
       
        if indexPath.row + 1 == self.myRank{
            self.myRankVisible = false
        }
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
            game.leftGame(name: name!)
            game = nil
            performSegue(withIdentifier: "leaveGame2", sender: nil)
         })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(yes)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
//

    
}


