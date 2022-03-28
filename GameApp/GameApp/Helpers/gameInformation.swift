//
//  gameInformation.swift
//  GameApp
//
//  Created by Daniel Goldberg on 3/24/22.
//

import Foundation
import UIKit
import Firebase
enum gameCodeError: Error {
  case dne
}
class gameInformation {
    enum joinCodeError: Error {
        case obvious
    }
    var db:Firestore! =  Firestore.firestore()
    var joinCode:String? = ""
    var host:String = ""
    var gameState:Bool = false 
    var gameName:String = ""
    var listner:ListenerRegistration? = nil
    var gameDesc:String = ""
    var numClues:Int = 0
    var numPlayers:Int = 0
    var maxPlayers:Int = 0
    var players:[String] = [""]
    init(game:[String:Any])  {
        self.gameState=game["started"] as! Bool
                    self.joinCode = (game["joinCode"] as! String)
                    self.host = game["host"] as! String
                    self.gameName = game["name"] as! String
                    self.gameDesc = game["description"] as! String
                    self.numClues = game["numberOfClues"] as! Int
                    self.numPlayers = game["participants"] as! Int
                    self.maxPlayers = game["maxParticipants"] as! Int
                    self.players = (game["playerNames"] as! String).components(separatedBy: " ")
//        self.listner = db.collection("currentGames").document(game["joinCode"] as! String).addSnapshotListener{ (querySnapshot,error) in
//            let gameInfo=querySnapshot?.data()
//        self.joinCode = gameInfo!["joinCode"] as? String
//        self.host = gameInfo!["host"] as! String
//        self.gameName = gameInfo!["name"] as! String
//        self.gameDesc = gameInfo!["description"] as! String
//        self.numClues = gameInfo!["numberOfClues"] as! Int
//        self.numPlayers = gameInfo!["participants"] as! Int
//        self.maxPlayers = gameInfo!["maxParticipants"] as! Int
//        self.players = (gameInfo!["playerNames"] as! String).components(separatedBy: " ")
//        }

    }
    
    func loadData(completed: @escaping () ->()){
        self.listner = db.collection("currentGames").document(joinCode!).addSnapshotListener{ [self](querySnapshot,error) in guard  error == nil else{
                print("Error in the snapshotListener")
                return completed()
            }
            let gameInfo=querySnapshot?.data()
        self.gameState = gameInfo!["started"] as! Bool
        self.joinCode = gameInfo!["joinCode"] as? String
        self.host = gameInfo!["host"] as! String
        self.gameName = gameInfo!["name"] as! String
        self.gameDesc = gameInfo!["description"] as! String
        self.numClues = gameInfo!["numberOfClues"] as! Int
        self.numPlayers = gameInfo!["participants"] as! Int
        self.maxPlayers = gameInfo!["maxParticipants"] as! Int
        self.players = (gameInfo!["playerNames"] as! String).components(separatedBy: " ")
            completed()
        }
    }
   
    func replacePlayers(existingPlayer:String,player: String){
        if let i = players.firstIndex(of: existingPlayer){
            players[i] = player
            db.collection("currentGames").document(joinCode!).updateData(["playerNames":players.joined(separator: " ")])
        }
        
        
    }
    func updatePlayers(player: String){
        let player = player
        db.collection("currentGames").document(joinCode!).updateData(["playerNames":players.joined(separator: " ") + " " + player,"participants":numPlayers+1])
    }
    func leftGame(name:String){
        db.collection("currentGames").document(joinCode!).updateData(["participants":self.numPlayers-1,"playerNames":players.filter{ $0 != name}.joined(separator:  " ")])
        
        self.listner?.remove()

    }
  
    
}




