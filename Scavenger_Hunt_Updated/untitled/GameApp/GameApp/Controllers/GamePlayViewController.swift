

import UIKit
import Firebase
class clueCell: UITableViewCell{
    @IBOutlet weak var clueName: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var clueFoundStatus: UIImageView!
    @IBOutlet weak var clueNum: UILabel!
    @IBOutlet weak var howManyPeopleSolved: UILabel!

}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }
}

class GamePlayViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
  
    @IBOutlet weak var ScanButton: UIButton!
    @IBAction func scanPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toScaner", sender: nil)
    }
    @IBAction func cluesPressed(_ sender: UIButton) {
    }
    @IBAction func leaderboardPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toLeader", sender: nil)
    }
    @IBAction func chatPressed(_ sender: UIButton) {
    }
    @IBOutlet weak var scanImage: UIImageView!
    @IBOutlet weak var clueImage: UIImageView!
    @IBOutlet weak var leaderboardImage: UIImageView!
    @IBOutlet weak var chatImage: UIImageView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "leaveGame"){
            game = nil
    }
        if (segue.identifier == "toScanner"){
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
        if (segue.identifier == "toLeader"){
            let destinationVC = segue.destination as!
                LeaderBoardViewController
            
            
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
    var cellTapped:[Bool]! = []
    @IBOutlet weak var clueTable: UITableView!
    @IBOutlet weak var LeaveButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var numClues:Int!
    var clueDescs:[String]!
    var clueSolved:[Bool]! = []
    var clueHints1:[String]!
    var clueHints2:[String]!
    @IBOutlet weak var joinCodeLabel: UILabel!
    var clueHints3:[String]!
    var clueHintsUsed:[Int]!
    var points:[String : [String : Any]]! = [:]
    var clueTotalSolves:[Int]!
    var clueIsHiddenUntil:[String]!
    var cluePointsWorth:[Int]!
    var clueExists:[Bool]!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var yourPoints: UILabel!
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage == leaderboardImage{
            performSegue(withIdentifier: "toLeader", sender: nil)        }
        else if tappedImage == scanImage{
            performSegue(withIdentifier: "toScaner", sender: nil)        }
        else if tappedImage == chatImage{
            print("Chat!")
        }
        
        // Your action
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        joinCodeLabel.text=game.joinCode
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        self.navigationController?.viewControllers = navigationArray
        print(navigationController.viewControllers)
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
        clueDescs =      Array(repeating: "", count: game.numClues)
        cellTapped = Array(repeating: false, count: game.numClues)
         clueHints1 =      Array(repeating: "", count: game.numClues)
         clueHints2 =      Array(repeating: "", count: game.numClues)
         clueHints3 =      Array(repeating: "", count: game.numClues)
         clueHintsUsed   =    Array(repeating: 0, count: game.numClues)
        
         clueTotalSolves =      Array(repeating: 0, count: game.numClues)
         clueIsHiddenUntil =      Array(repeating: "", count: game.numClues)
         cluePointsWorth =      Array(repeating: 0, count: game.numClues)
         clueExists =      Array(repeating: true, count: game.numClues)
        clueSolved = Array(repeating: false, count: game.numClues)
        numClues = game.numClues
       
        game.loadData {
            print("game refreshed")
        }
        game.loadClueData {
            print("clue refresh")
            for clueInfo in
                self.game.clueInfo.values {
              
                self.clueDescs[(clueInfo["name"] as! Int) - 1] = clueInfo["description"] as! String
             
                self.clueHints1[clueInfo["name"] as! Int - 1 ] = clueInfo["hint1"] as! String
                self.clueHints2[clueInfo["name"] as! Int - 1] = clueInfo["hint2"] as! String
               
                self.clueTotalSolves[clueInfo["name"] as! Int - 1 ] = clueInfo["howManySolves"] as! Int
                self.clueIsHiddenUntil[clueInfo["name"] as! Int - 1] = clueInfo["hiddenUntilFollowingAreSolved"] as! String
                self.cluePointsWorth[clueInfo["name"] as! Int - 1] = clueInfo["points"] as! Int
                self.clueExists[clueInfo["name"] as! Int - 1] = clueInfo["exists"] as! Bool
                self.clueHints3[clueInfo["name"] as! Int - 1] = clueInfo["hint3"] as! String
            }
            self.clueTable.reloadData()
        }
        game.loadYourPlayerData(player: self.name!){
            if self.game.myInfo != nil{
            print("your player refresh")
            self.pointLabel.text = String(self.game.myInfo["points"] as! Int)
            let solveds = self.game.myInfo["solveds"] as! String
            for solved in solveds.split(separator: ","){
                self.clueSolved[Int(solved)!-1] = true
            }
            self.clueTable.reloadData()

            }}
       
        
        yourPoints.text = "Your Points ( \(self.name!) ): "
        
//        clueTable.register(clueCell.self,
//                            forCellReuseIdentifier: "TableViewCell")
        clueTable.dataSource = self
        clueTable.delegate = self
        

    }
    
    
    
    
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clueDescs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = clueTable.dequeueReusableCell(withIdentifier: "TableViewCell",
            for: indexPath) as! clueCell
        
       
        if clueExists[indexPath.row] == true{
            cell.clueName?.font = UIFont.systemFont(ofSize: 17)
            cell.clueName?.textColor = .black
            cell.clueName?.textAlignment = .left
        cell.clueNum?.text = String(indexPath.row + 1)
        if self.clueSolved[indexPath.row] == false{
            cell.clueFoundStatus.image = UIImage(systemName: "questionmark")
            cell.clueFoundStatus?.tintColor = .systemRed
            cell.backgroundColor = .none

        }
        else{
            cell.clueFoundStatus?.image = UIImage(systemName: "checkmark.circle.fill")
            cell.clueFoundStatus?.tintColor = .blue
            cell.backgroundColor = .green
        }
        cell.pointLabel?.text = String(cluePointsWorth[indexPath.row]) + "\npoints"
        if cellTapped[indexPath.row] == false{
            cell.howManyPeopleSolved?.text = ""
            cell.howManyPeopleSolved?.backgroundColor = .none
        }
        else{
          
            cell.howManyPeopleSolved?.text = String(clueTotalSolves[indexPath.row]) + " people have solved this clue so far"
            cell.howManyPeopleSolved?.backgroundColor = .black
        }
        let fnt = clueDescs[indexPath.row].height(withConstrainedWidth: clueTable.bounds.width - 37 - 95, font: .systemFont(ofSize: 17))
        if fnt > 52 && cellTapped[indexPath.row] == false
        {
            cell.clueName?.text = self.clueDescs[indexPath.row].prefix(42)+"..."
         
        }
        else{
            
            cell.clueName?.text = self.clueDescs[indexPath.row ]
        }
        }
        else{
            cell.clueFoundStatus?.image = UIImage(systemName: "exmark")
            cell.clueFoundStatus?.tintColor = .gray
             cell.clueName?.text = "Clue Deleted"
            cell.clueName?.font = UIFont.systemFont(ofSize: 30)
            cell.clueName?.textColor = .gray
            cell.clueName?.textAlignment = .center
            cell.pointLabel?.text = ""
            cell.howManyPeopleSolved?.text = ""
        }
        return cell
            
    }

   

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
            if  self.cellTapped[indexPath.row] == false{
                self.cellTapped[indexPath.row] = true
            }
            else{
                self.cellTapped[indexPath.row] = false
                
            }
        
            clueTable.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if self.cellTapped[indexPath.row] == false{
            return 70
        }
        else{
            return UITableView.automaticDimension
        }
        
        
        
    }
     
    
    @IBAction func leaveGame(_ sender: UIButton) {
        var dialogMessage = UIAlertController(title: "Leave This Game?", message: "Are you sure you want to leave the game?", preferredStyle: .alert)
        
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
            performSegue(withIdentifier: "leaveGame", sender: nil)
         })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(yes)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
//

    
}


