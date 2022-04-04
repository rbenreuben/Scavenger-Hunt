import UIKit
import FirebaseAuth
import Firebase

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var UserN: UILabel!
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
 
    
    
    
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
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var arrayDesc = [""]
    var arrayImage: [UIImage?] = [UIImage(named: "")]
    var myIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! DetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.desc = arrayDesc[selectedIndexPath.row]
            destination.img = arrayImage[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
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
    
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Clue " + String(indexPath.row + 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.row != 0 {
            arrayDesc.remove(at: indexPath.row)
            arrayImage.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            for i in 1...arrayDesc.count+1 {
                let indexP = IndexPath(row: i, section: 0)
                tableView.cellForRow(at: indexP)?.textLabel?.text = "Clue " + String(i+1)
            }
        }
    }
    
    
}
