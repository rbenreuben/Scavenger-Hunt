import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var SignUp: UIButton!
    @IBOutlet weak var Login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }

    func setUpElements() {
        Utilities.styleFilledButton(SignUp)
        Utilities.styleHollowButton(Login)
    }
}

