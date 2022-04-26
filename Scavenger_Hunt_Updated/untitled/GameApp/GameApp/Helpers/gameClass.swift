//
//  Game Class.swift
//  GameApp
//
//  Created by RazBerry_Pi on 4/11/22.
//

import Foundation
import UIKit
import Firebase

class gameObject{
    var gameName:String!
    var joinCode:String!
    var gameDesc:String!
    var maxPlayers:Int!
    var numberOfClues:Int!
    var hasChat:Bool!
    var host:String!
    var timeLimit:Int! //-1 means no time limit
    var cluesInfo:[[String:Any]]!

    init(){
        gameName=""
        gameDesc=""
        maxPlayers = -1
        numberOfClues = 0
        hasChat = true
        host = ""
        timeLimit = -1
        cluesInfo = []
        joinCode=""
    }

}
