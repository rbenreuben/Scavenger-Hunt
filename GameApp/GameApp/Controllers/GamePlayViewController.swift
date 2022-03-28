//
//  GamePlayViewController.swift
//  GameApp
//
//  Created by Daniel Goldberg on 3/28/22.
//

import UIKit

class GamePlayViewController: UIViewController {
    var game:gameInformation!
    var name:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        game.loadData {
            print(self.name)
        }
            
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
