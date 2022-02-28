import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    
    
    @IBAction func addData(_ sender: Any) {
        
        //This creates a collection and document with data
        db.collection("usersPractice").document("uid")
            .setData([
            "first":"Ari",
            "last":"Zaravelis",
            "dob":"11/13/1999"]){
                Err in
                if let oErr = Err {
                    print("Error: \(oErr)")
                }
                else
                {
                    print("document added")
                }
            }
        
        //This creates a collection and document with data, however, the document is randomly generated.
        db.collection("usersPractice").addDocument(data: [
            "first":"Ari",
            "last":"Zaravelis",
            "dob":"11/13/1999"]){
            Err in
            if let oErr = Err {
                print("Error: \(oErr)")
            }
            else
            {
                print("document added")
            }
        }
        
        //This updates data using updateData method.
        db.collection("usersPractice").document("uid").updateData([
            "first":"Ari",
            "last":"Zaravelis",
            "dob":"11/13/1966"]){
                Err in
                if let oErr = Err {
                    print("Error: \(oErr)")
                }
                else
                {
                    print("document added")
                }
            }
        
    }
    
    
    @IBAction func getData(_ sender: Any) {
        
        /*db.collection("usersPractice").getDocuments(){(querySanpshot, err) in
            
            if let oErr = err {
                print("Error: \(oErr.localizedDescription)")
            }
            else
            {
                for document in querySanpshot!.documents
                {
                    self.textView_NameList.text.append(contentsOf: "\(document.documentID):\(document.data())\n")
                }
            }
        }*/
        
        db.collection("usersPractice").whereField("dob",isNotEqualTo: "11/13/1966").getDocuments(){(querySanpshot, err) in
            
            if let oErr = err {
                print("Error: \(oErr.localizedDescription)")
            }
            else
            {
                for document in querySanpshot!.documents
                {
                    self.textView_NameList.text.append(contentsOf: "\(document.documentID):\(document.data())\n")
                }
            }
        }
        
        
        
    }
    
    
    @IBOutlet weak var textView_NameList: UITextView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func signup(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!) {(user, error) in
            if user != nil {
                print("User Has Signed Up!")
            }
            if error != nil {
                print("User Could Not Sign Up!")
            }
        }
    }
    
    @IBAction func signin(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) {(user, error) in
            if user != nil {
                print("User Has Signed In!")
            }
            if error != nil {
                print("User Could Not Sign In!")
            }
        }
    }
    
    
}
