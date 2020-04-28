//
//  GameView.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-24.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI

typealias reset = () -> Void

struct GameView: View {
    var backButton: reset?
    
    var body: some View {
        VStack(spacing: 20) {
            _header(backButton: backButton!)
            
            Spacer()
            
            _board()
            
            Spacer()
            
            _uiCluster()
        }
    }
    
    //================= VIEWS ================
    /*
     This renders header of game view
     */
    struct _header: View {
        // setting view toggler
        @State var isSettingOpen: Bool = false
        
        // input for more option
        var backButton: reset
        
        // Text copies
        var titleCopy: String = "WORD SEARCH"
        
        var body: some View {
            HStack {
                // back button
                Button(action: {
                    self.backButton()
                }) {
                    Image(systemName: "arrow.left")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                }.padding(.horizontal)
                
                Spacer()
                
                // header
                Text(titleCopy)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                
                Spacer()
                
                // setting
                Button(action: {
                    self.isSettingOpen = true
                }) {
                    Image(systemName: "ellipsis")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                }.padding(.horizontal)
                    .sheet(isPresented: $isSettingOpen, content: { SettingView() })
            }.padding(.top, 20)
        }
    }
    
    
    /*
     This renders game board. default board size is 10
     */
    struct _board: View {
        @ObservedObject var game: Game = Game.sharedInstance
        
        @State var selectedCells: [Location] = []
        @State var keywordBuilder: String = ""
        @State var lastLoc: Location?
        
        var body: some View {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    ForEach (self.game.gameBoard, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach (row, id: \.self) { cell in
                                cell
                            }
                        }
                    }
                }.gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local) // using local coordinates -- no need to get viewframe's origin location
                        .onChanged { value in
                            self.__handleSelect(touch: value)
                        }
                        .onEnded { _ in
                            self.__validateSelection()
                        }
                ).padding(.horizontal, 10)
            }
        }
        
        
        //======================== board helpers ========================
        /*
         This handles cell selection
         Stores correcponding Cell and its string value to self.keywordBuilder and self.selectedCells.
         */
        private func __handleSelect(touch: DragGesture.Value) {
            var xLoc: Int = Int((touch.location.x - 2) / Cell.scale)               // (touch locatioin - left padding) / cell size
            var yLoc: Int = Int((touch.location.y) / Cell.scale)                     // (touch location) / cell size
            
            // upper bound check
            xLoc = (xLoc > Game.boardSize - 1) ? Game.boardSize - 1 : xLoc
            yLoc = (yLoc > Game.boardSize - 1) ? Game.boardSize - 1 : yLoc
            // loser bound check
            xLoc = (xLoc < 0 ? 0 : xLoc)
            yLoc = (yLoc < 0 ? 0 : yLoc)
            
            
            let targetLocation: Location = Location(yLoc: yLoc, xLoc: xLoc)
            if self.lastLoc == nil || (targetLocation != self.lastLoc) {
                print("[" + String(yLoc) + "][" + String(xLoc) + "]")
                if !self.game.gameBoard[yLoc][xLoc].isSelected {
                    self.game.gameBoard[yLoc][xLoc]._toggleSelect()
                }
                self.selectedCells.append(targetLocation)
                self.keywordBuilder.append(self.game.gameBoard[yLoc][xLoc].value ?? "?")
                self.lastLoc = targetLocation
            }
        }
        
        /*
         This handles selection validation
         Validates if the selected cells are correct, and consolidates cell selection.
         It resets self.keywordBuilder and remove the cells from self.selectedCells.
         */
        private func __validateSelection() {
            // not answer
            if !Game.keywordList.contains(self.keywordBuilder) {
                for loc in self.selectedCells {
                    if self.game.gameBoard[loc.yLoc][loc.xLoc].isSelected {
                        self.game.gameBoard[loc.yLoc][loc.xLoc]._toggleSelect()
                    }
                }
                print("incorrect!")
            } else {
                self.game.score += 1
                print("Score: " + String(self.game.score))
            }
            // answer
            self.lastLoc = nil
            self.keywordBuilder = ""
            self.selectedCells.removeAll()
        }
        
        //===============================================================
    }
    
    /*
     This renders UI.
     - Number of words found
     - Number of words to be found
     - Hint
     - Reset
     */
    struct _uiCluster: View {
        @ObservedObject var game = Game.sharedInstance

        var body: some View {
            VStack(spacing: 40) {
                // row 1
                HStack(spacing: 15) {
                    Spacer()
                    Text("FOUND: " + String(game.score))
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Spacer()
                    Text("LEFT: " + String(Game.keywordList.count - game.score))
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Spacer()
                }
                // row 2
                HStack(spacing: 15) {
                    Spacer()
                    Button(action: {
                        self.game._resetGame()
                    }) {
                        Text("RESET")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        if self.game.getHintCount() > 0 {
                            self.game._showMeTheHint()
                        }
                    }) {
                        Text("HINT(" + String(self.game.getHintCount()) + ")")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
            }.padding(.bottom, 40)
        }
    }
    //========================================
}

