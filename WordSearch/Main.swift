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
    
    @State var isRunning: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // good for eyes

            // new try with swiftUI
            // This somehow adds up memory about 1-2mb whenever navigation happens.
            // NavigationLink probably could be better i guess
                if !isRunning {
                    MainView(startFunction: self._startGame).animation(.easeInOut)
                } else {
                    GameView(backButton: self._toMain).animation(.easeInOut)
                }
            }
        }
    
    //============== Behaviours ==============
    public func _startGame() -> Void {
        isRunning = true
        self.game._resetGame() // randomize whenever user starts a new game
    }
    
    public func _toMain() -> Void {
        isRunning = false
    }
    //========================================
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
