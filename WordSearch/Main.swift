//
//  ContentView.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-24.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var game: Game = Game.sharedInstance
    
    var body: some View {
        ZStack {
            Color.orange.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            // new try with swiftUI
            // This somehow adds up memory about 1-2mb whenever navigation happens.
            // NavigationLink probably could be better i guess
            if !self.game.isRunning {
                    MainView(startFunction: self._startGame).animation(.easeInOut)
                } else {
                    GameView(backButton: self._toMain).animation(.easeInOut)
                }
            }
        }
    
    //============== Behaviours ==============
    public func _startGame() -> Void {
        self.game.isRunning = true
        self.game._resetGame() // randomize whenever user starts a new game
    }
    
    public func _toMain() -> Void {
        self.game.isRunning = false
    }
    //========================================
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
