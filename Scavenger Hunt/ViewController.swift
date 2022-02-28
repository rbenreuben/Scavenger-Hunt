import UIKit
import FirebaseFirestore


class ViewController: UIViewController, UITextFieldDelegate {
    
    let db = Firestore.firestore()
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter Name..."
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(field)
        field.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        field.frame = CGRect(x: 10,
                             y: view.safeAreaInsets.top+10,
                             width: view.frame.size.width-20,
                             height: 50)
        label.frame = CGRect(x: 10,
                             y: view.safeAreaInsets.top+10+60,
                             width: view.frame.size.width-20,
                             height: 100)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            saveData(text: text)
        }
        return true
    }
    
    
    func saveData(text: String) {
        let docRef = db.collection("AriPractice").document(text)
        docRef.getDocument {snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            print(data)
            
//        let docRef = database.document("tutorialfirebase/users")
//        docRef.setData(["Name": text])
    }
}

}
