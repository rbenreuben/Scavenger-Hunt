import UIKit
import FirebaseAuth
import Firebase
import PDFKit

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var actualGame:gameInformation!
    var game:gameObject!
    var gameName:String!
    var gameDesc:String!
    var duration:Int!
    var clueCodes=[""]
    //cluesInfo [ ["description":"clue 1","points":100],  ["description":"clue 2","points":100]  ]
    var maxPlayers: Int!
    /*
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
            
            
            db.collection("mail").document("example").setData([
                "to": Auth.auth().currentUser?.email,
                "message": [
                    "subject": "Scavenger Hunt App QR Codes!",
                    "html": "This is an <code>HTML</code> email body.",
                    "attachments": [
                        "content": img.jpegData(compressionQuality: 0.5),
                        "filename": "attachment.jpg",
                        "type": "application/jpg",
                        "disposition": "attachment"
                      ]
                ]
            ])
            
            
        
        }
    }
    */
    
    /*
    @IBAction func printQR(_ sender: UIButton) {
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .general
        printInfo.jobName = "My Print Job"
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = qrCode.image
        printController.present(animated: true, completionHandler: nil)
    }
    */
    
    
    @IBOutlet weak var gameNameField: UITextField!
    
    
    @IBOutlet weak var gameDescriptionField: UITextField!
    
    
    @IBOutlet weak var gameDurationField: UITextField!
    
    
    @IBOutlet weak var createGameButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    @IBOutlet weak var numberOfPlayersLabel: UILabel!
    
    @IBOutlet weak var numberOfPlayersField: UITextField!
    
    var arrayDesc = [""]
    var arrayImage: [UIImage?] = [UIImage(named: "")]
    var myIndex = 0
    var joinCode=""
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        createJoinCode()
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    
    
    @IBAction func createGamePressed(_ sender: UIButton) {
        if joinCode != ""{
        game = gameObject()
        game.gameName = gameNameField.text
        game.gameDesc = gameDescriptionField.text
        game.timeLimit = Int(gameDurationField.text!)
        game.maxPlayers = -1
        game.host =  Auth.auth().currentUser?.email
        print(game.host)
        game.maxPlayers = Int(numberOfPlayersField.text!)
        game.joinCode=joinCode
        
        print(game.maxPlayers!)
        print(game.gameName!)
        print(game.gameDesc!)
        print(game.timeLimit!)
        let db = Firestore.firestore()
            
        db.collection("currentGames").document(joinCode).setData(["description":self.game.gameDesc,"name":game.gameName,"maxParticipants":game.maxPlayers,"joinCode":joinCode,"host":game.host,"numberOfClues":0,"participants":0,"playerNames":"","started":false,"timeToEnd":0,"duration":game.timeLimit])
            
            
                               var count = 1
                            
                                    for (index, cell) in tableView.visibleCells.enumerated(){
                                        db.collection("currentGames").document(joinCode).collection("clues").document("clues"+String(count)).setData(["description":arrayDesc[count-1],"points":100,"name": count,"howManySolves":0,"exists":true,"qrCode":clueCodes[count-1].suffix(4),"totalHints":0,"numberOfHints":3,"hint1":"1","hint2":"2","hint3":"3","hiddenUntilFollowingAreSolved":""])
                                count = count+1
                                }
            
            let docRef = db.collection("currentGames").document(self.joinCode)
            docRef.getDocument {  (document, error )    in
                if let document = document, document.exists {
                    let gameInfo = document.data()
                    let game = gameInformation(game: gameInfo!)
       
                    self.actualGame=game
                    var attachments = [[String:Any]]()
                    for i in stride(from: 0, to: self.tableView.numberOfRows(inSection: 0), by: 2) {
                        
                        if(i+1 != self.tableView.numberOfRows(inSection: 0)) {
                            var attachment = [
                                "content": self.createPdf(num: i),
                                "filename": "Clue\(i+1)AndClue\(i+2).pdf",
                                "type": "application/pdf",
                                "disposition": "attachment"
                            ] as [String : Any]
                            attachments.append(attachment)
                        }
                        else {
                            var attachment = [
                                "content": self.createPdf(num: i),
                                "filename": "Clue\(i+1).pdf",
                                "type": "application/pdf",
                                "disposition": "attachment"
                            ] as [String : Any]
                            attachments.append(attachment)
                        }
                        
                    }
                    
                    
                    db.collection("mail").document(self.joinCode).setData([
                        "to": Auth.auth().currentUser?.email,
                        "message": [
                            "subject": "Scavenger Hunt App QR Codes!",
                            "html": "Below are the attached QR codes correspoding to the clues you created. Print theses QR codes and place them in the desired locations.",
                            "attachments": attachments
                        ]
                    ])
                      
                    self.performSegue(withIdentifier: "toHostLobby", sender: nil)
            }
        }
          
        }
        
        
    }
    func createJoinCode()  {
        let db = Firestore.firestore()
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "1234567890"
            let firstLetter = letters.randomElement()
            let secondLetter = letters.randomElement()
            let firstNumber = numbers.randomElement()
            let secondNumber = numbers.randomElement()
            let joinCodeTest = String(firstLetter!) + String(secondLetter!) + String(firstNumber!) + String(secondNumber!)
            
            let docRef = db.collection("currentGames").document(joinCodeTest)
         docRef.getDocument{ [self]
                (document,error) in
                if let document = document,document.exists{
                     createJoinCode()
                }
                else{
                    db.collection("currentGames").document(joinCodeTest).setData(["joinCode":joinCodeTest,"ended":true])

                    db.collection("currentGames").document(joinCodeTest).collection("participants").document("null null").setData(["name":"null null"])
                    self.joinCode = joinCodeTest
                }
            }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(joinCode)
        if joinCode != ""{
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! DetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.desc = arrayDesc[selectedIndexPath.row]
            destination.img = arrayImage[selectedIndexPath.row]
            if clueCodes[selectedIndexPath.row]==""{
                clueCodes.append("")
                let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                let numbers = "1234567890"
                var code = ""
                while true{
                    let firstLetter = letters.randomElement()
                    let secondLetter = letters.randomElement()
                    let firstNumber = numbers.randomElement()
                    let secondNumber = numbers.randomElement()
                    code = String(firstLetter!) + String(secondLetter!) + String(firstNumber!) + String(secondNumber!)
                    if !(self.clueCodes.contains(code)){
                        break
                    }
                }
                self.clueCodes[selectedIndexPath.row] = self.joinCode + "CLU" + String(selectedIndexPath.row+1)+"_"+code
                
            }
            destination.clueCode = self.clueCodes[selectedIndexPath.row]


        } else if segue.identifier == "AddDetail"{
            let navDest = segue.destination as! UINavigationController
            let destination = navDest.viewControllers.first as! DetailTableViewController

            let selectedIndexPath = tableView.numberOfRows(inSection: 0)
            clueCodes.append("")
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let numbers = "1234567890"
            var code = ""
            while true{
                let firstLetter = letters.randomElement()
                let secondLetter = letters.randomElement()
                let firstNumber = numbers.randomElement()
                let secondNumber = numbers.randomElement()
                code = String(firstLetter!) + String(secondLetter!) + String(firstNumber!) + String(secondNumber!)
                if !(self.clueCodes.contains(code)){
                    break
                }
            }
            self.clueCodes[selectedIndexPath] = self.joinCode + "CLU" + String(selectedIndexPath+1)+"_"+code
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
            destination.clueCode = self.clueCodes[selectedIndexPath]

        }
        else if segue.identifier=="toHostLobby"{
            let destination = segue.destination as! HostLobbyViewController
            destination.game=self.actualGame
            destination.joinCode=self.joinCode
            let db = Firestore.firestore()
            db.collection("currentGames").document(joinCode).updateData(["numberOfClues":tableView.numberOfRows(inSection: 0)])
            
            
        }
    }
    }
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! DetailTableViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            arrayDesc[selectedIndexPath.row] = source.desc
            arrayImage[selectedIndexPath.row] = source.img
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: arrayDesc.count, section: 0)
            arrayDesc.append(source.desc)
            arrayImage.append(source.img)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
    }

func createPdf(num: Int) -> Data {
    let pageWidth = 8.5 * 72.0
    let pageHeight = 11 * 72.0
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

  
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
  
    let data = renderer.pdfData { (context) in
        
        context.beginPage()
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32)
        ]
        
        if(num+1 != tableView.numberOfRows(inSection: 0)) {
            let text1 = "Clue \(num+1)"
            text1.draw(at: CGPoint(x: 270, y: 0), withAttributes: attributes)
        
            let maxHeight = pageRect.height * 0.4
            let maxWidth = pageRect.width * 0.8
            let aspectWidth = maxWidth / arrayImage[num]!.size.width
            let aspectHeight = maxHeight / arrayImage[num]!.size.height
            let aspectRatio = min(aspectWidth, aspectHeight)
            let scaledWidth = arrayImage[num]!.size.width * aspectRatio
            let scaledHeight = arrayImage[num]!.size.height * aspectRatio
            let imageX = (pageRect.width - scaledWidth) / 2.0
            let imageRect1 = CGRect(x: imageX, y: 50, width: scaledWidth, height: scaledHeight)
            
            arrayImage[num]!.draw(in: imageRect1)
            
            
            let text2 = "Clue \(num+2)"
            text2.draw(at: CGPoint(x: 270, y: 400), withAttributes: attributes)
            
            let imageRect2 = CGRect(x: imageX, y: 450, width: scaledWidth, height: scaledHeight)
            
            arrayImage[num+1]!.draw(in: imageRect2)
            
        }
        else {
            let text1 = "Clue \(num+1)"
            text1.draw(at: CGPoint(x: 270, y: 0), withAttributes: attributes)
        
            let maxHeight = pageRect.height * 0.4
            let maxWidth = pageRect.width * 0.8
            let aspectWidth = maxWidth / arrayImage[num]!.size.width
            let aspectHeight = maxHeight / arrayImage[num]!.size.height
            let aspectRatio = min(aspectWidth, aspectHeight)
            let scaledWidth = arrayImage[num]!.size.width * aspectRatio
            let scaledHeight = arrayImage[num]!.size.height * aspectRatio
            let imageX = (pageRect.width - scaledWidth) / 2.0
            let imageRect1 = CGRect(x: imageX, y: 50, width: scaledWidth, height: scaledHeight)
            
            arrayImage[num]!.draw(in: imageRect1)
        }
        
    }
    print(data)
    return data
}
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if joinCode != "" {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Clue " + String(indexPath.row + 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && tableView.numberOfRows(inSection: 0) > 1 {
            arrayDesc.remove(at: indexPath.row)
            arrayImage.remove(at: indexPath.row)
            clueCodes.remove(at:indexPath.row)
            if clueCodes.count>indexPath.row{
                let code=clueCodes[indexPath.row].suffix(4)
                clueCodes[indexPath.row]=self.joinCode + "CLU" + String(indexPath.row+1)+"_"+String(code)
                
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            for i in 1...arrayDesc.count+1 {
                let indexP = IndexPath(row: i, section: 0)
                tableView.cellForRow(at: indexP)?.textLabel?.text = "Clue " + String(i+1)
                
            }
        }
    }
}
