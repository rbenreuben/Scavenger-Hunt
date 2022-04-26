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
    var clueListener:ListenerRegistration? = nil
    var playersListener:ListenerRegistration? = nil
    var yourPlayerListener:ListenerRegistration? = nil
    var gameDesc:String = ""
    var numClues:Int = 0
    var numPlayers:Int = 0
    var maxPlayers:Int = 0
    
    var players:[String] = [""]
    var clueInfo : [String : [String : Any]]! = [:]
    var myInfo :[String:Any]! = [:]
    var playerInfo : [String : [String : Any]]! = [:]
    var cluePointsWorth:[Int]!
    var clueExists:[Bool]!
    init(game:[String:Any])  {
        self.gameState=game["started"] as! Bool
                    self.joinCode = (game["joinCode"] as! String)
                    self.host = game["host"] as! String
                    self.gameName = game["name"] as! String
                    self.gameDesc = game["description"] as! String
        self.joinCode=game["joinCode"] as! String
                    self.numClues = game["numberOfClues"] as! Int
                    self.numPlayers = game["participants"] as! Int
                    self.maxPlayers = game["maxParticipants"] as! Int
                    self.players = (game["playerNames"] as! String).components(separatedBy: " ")
        


    }
    
    func loadClueData(completed: @escaping () ->()){
        self.clueListener = db.collection("currentGames").document(joinCode!).collection("clues").addSnapshotListener{
            [self](querySnapshot,error) in
            guard  let documents =  querySnapshot?.documents  else{
                    print("no clues")
                    return completed()
                }
            documents.map{
              queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
                clueInfo[String(data["name"] as! Int) ] = data
            }
             completed()
        }
        }
    func loadYourPlayerData(player: String,completed: @escaping () ->()){
        print(player)
        self.yourPlayerListener = db.collection("currentGames").document(joinCode!).collection("participants").document(player).addSnapshotListener{
            [self](querySnapshot,error) in guard  error == nil else{
                    print("Error in the snapshotListener")
                    return completed()
                }
                let data=querySnapshot?.data()
                self.myInfo = data
        completed()

            }
        }
    
    func loadPlayerData(completed: @escaping () ->()){
        self.playersListener = db.collection("currentGames").document(joinCode!).collection("participants").addSnapshotListener{
            [self](querySnapshot,error) in
            guard  let documents =  querySnapshot?.documents  else{
                    print("no players")
                    return completed()
                }
            documents.map{
              queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
  
                if data.count > 0 {
                  
                    playerInfo[queryDocumentSnapshot.documentID ] = data
                }
            }
             completed()
        }
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
            let docRef = db.collection("currentGames").document(joinCode!).collection("participants").document(existingPlayer)
                
                docRef.getDocument {  (document, error )    in
                    if let document = document, document.exists {
                        var data = document.data()
                        data!["name"] = player
                        self.db.collection("currentGames").document(self.joinCode!).collection("participants").document(player).setData(data!);        self.db.collection("currentGames").document(self.joinCode!).collection("participants").document(existingPlayer).delete()
                        
                    }
             
                }}
        
    }
        
    func updatePlayers(player: String){
        let player = player
        db.collection("currentGames").document(joinCode!).updateData(["playerNames":players.joined(separator: " ") + " " + player,"participants":numPlayers+1])
        db.collection("currentGames").document(joinCode!).collection("participants").document(player).setData(["name":player,"points":0,"solveds":""])
    }
    func leftGame(name:String){
        self.listner?.remove()
        self.playersListener?.remove()
        self.clueListener?.remove()
        self.yourPlayerListener?.remove()
        db.collection("currentGames").document(joinCode!).updateData(["participants":self.numPlayers-1,"playerNames":players.filter{ $0 != name}.joined(separator:  " ")])
        self.db.collection("currentGames").document(self.joinCode!).collection("participants").document(name).delete()
        print("leftGame")
    }
  
    func hostLeftGame(name:String){
        self.listner?.remove()
        self.playersListener?.remove()
        self.clueListener?.remove()
        self.yourPlayerListener?.remove()
        db.collection("currentGames").document(joinCode!).delete()
        print("leftGame")
    }
  
}





