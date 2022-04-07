import UIKit

class DetailTableViewController: UITableViewController {

    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var clueDescriptionField: UITextField!
    @IBOutlet weak var qrCode: UIImageView!
    
    @IBAction func QRGenerateButtonPressed(_ sender: Any) {
        if let myString = clueDescriptionField.text {
            let data = myString.data(using: String.Encoding.ascii)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            
            let image = UIImage(ciImage: (filter?.outputImage)!)
            
            qrCode.image = image
        }
    }
    
    var desc: String!
    var img: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if desc == nil {
            desc = ""
        }
        
        if img == nil {
            img = UIImage(contentsOfFile: "")
        }

        clueDescriptionField.text = desc
        qrCode.image = img
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        desc = clueDescriptionField.text
        img = qrCode.image
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}
