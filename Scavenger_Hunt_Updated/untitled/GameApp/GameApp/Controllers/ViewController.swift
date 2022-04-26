//
//  ViewController.swift
//  GameApp
//
//  Created by Daniel Garcia on 2/17/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var SignUp: UIButton!
    @IBOutlet weak var Login: UIButton!
    
    @IBOutlet weak var Join: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        if navigationArray.count>=2{
        navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController

        self.navigationController?.viewControllers = navigationArray
    }
        print(navigationController.viewControllers)

        setUpElements()
    }

    func setUpElements() {
        Utilities.styleFilledButton(SignUp)
        Utilities.styleHollowButton(Login)
        Utilities.styleHollowButton(Join)

    }
}

