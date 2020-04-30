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
    var game: Game = Game.sharedInstance
    var backButton: reset?
    
    var body: some View {
        return GeometryReader { geometry in
            ZStack {
                // height is greater than the width -> portrait mode
                if geometry.size.width < geometry.size.height {
                    VStack(spacing: 20) {
                        _header(backButton: self.backButton!)
                        _timer()
                        _board()
                        Spacer()
                        _uiCluster()
                    }
                }
                // width is greater than the height -> horizontal mode
                else {
                    HStack(spacing: 20) {
                        VStack {
                            _header(backButton: self.backButton!)
                            _timer()
                            Spacer()
                            _uiCluster()
                        }
                        _board()
                    }
                }

                if self.game.isEnd {
                    GeometryReader { _ in
                        YouBeatTheGame(backButton: self.backButton!)
                    }.background(Color.black.opacity(0.7))
                        .edgesIgnoringSafeArea(.all)
                } else if self.game.isDead {
                    GeometryReader { _ in
                        YouDied(backButton: self.backButton!)
                    }.background(Color.black.opacity(0.7))
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
    
    //================= VIEWS ================
    /*
     This renders header of game view
     I should have used navigation view
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
                    .sheet(isPresented: $isSettingOpen, content: { WordListView() })
            }.padding(.top, 20)
        }
    }
    
    /**
     User has a minute to finish the word search game.
     If user failed to finish, this toggles Game.isDead to true
     */
    struct _timer: View {
        @ObservedObject var game: Game = Game.sharedInstance
        
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            Text("\(self.game.timeRemaining)")
                .font(.system(size: 40))
                .onReceive(timer) { _ in
                    // game must be running
                    if self.game.timeRemaining > 0 && !self.game.isEnd {
                        self.game.timeRemaining -= 1
                    } else {
                        self.game.isDead = true
                    }
                }
        }
    }
    
    
    /*
     This renders game board. default board size is 10
     */
    struct _board: View {
        @ObservedObject var game: Game = Game.sharedInstance
        @State var selectedCells: [Location] = []
        @State var keywordBuilder: String = ""
        @GestureState private var dragOffset = CGSize.zero

        
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
                    DragGesture(minimumDistance: 0, coordinateSpace: .local) // using local coordinates
                        .updating(self.$dragOffset, body: { (value, state, transaction) in
                            state = value.translation
                        })
                        .onChanged { value in
                            self.__handleSelect(touch: value)
                        }
                        .onEnded { _ in
                            print("end")
                            self.__validateSelection()
                        }
                ).padding(.top, 10)
            }
        }
        
        //======================== board helpers ========================
        /*
         This handles cell selection
         Stores correcponding Cell and its string value to self.keywordBuilder and self.selectedCells.
         Since this depends on coordinates, everything should be variable based on screen size.
         */
        private func __handleSelect(touch: DragGesture.Value) {
            var xLoc: Int = Int((touch.location.x - 2) / Cell.scale)               // (touch locatioin - left padding) / cell size
            var yLoc: Int = Int((touch.location.y) / Cell.scale)                     // (touch location) / cell size

            // upper bound check
            xLoc = (xLoc > Game.boardSize - 1) ? Game.boardSize - 1 : xLoc
            yLoc = (yLoc > Game.boardSize - 1) ? Game.boardSize - 1 : yLoc
            // lower bound check
            xLoc = (xLoc < 0 ? 0 : xLoc)
            yLoc = (yLoc < 0 ? 0 : yLoc)
            
            let targetLocation: Location = Location(yLoc: yLoc, xLoc: xLoc)
            if targetLocation != self.selectedCells.last {
                print("[" + String(yLoc) + "][" + String(xLoc) + "]")
                
                // record selection info
                self.selectedCells.append(targetLocation)
                self.keywordBuilder.append(self.game.gameBoard[yLoc][xLoc].value ?? "?")
                
                // mutating cells based on dragging location stops after 1 seconds of touch action.. can't find any good solution to it :(
//                self.game.gameBoard[yLoc][xLoc]._select()
//                self.game.gameBoard[yLoc][xLoc]._magnify()
            }
        }
        
        /*
         This handles selection validation
         Validates if the selected cells are correct, and consolidates cell selection.
         It resets self.keywordBuilder and remove the cells from self.selectedCells.
         */
        private func __validateSelection() {
            // incorrect answer
            if !Game.keywordList.contains(self.keywordBuilder) || self.game.getKeywordsFound().contains(self.keywordBuilder) {
                for loc in self.selectedCells {
                    self.game.gameBoard[loc.yLoc][loc.xLoc]._deselect()
                }
            } else if Game.keywordList.contains(self.keywordBuilder) && !self.game.getKeywordsFound().contains(self.keywordBuilder) {
                self.game.score += 1 // show the result to user FIRST
                self.game._addKeywordsFound(keywords: self.keywordBuilder)
                for loc in self.selectedCells {
                    self.game.gameBoard[loc.yLoc][loc.xLoc]._answered()
                }
                if Game.keywordList.count - self.game.score == 0 {
                    self.game.isEnd = true
                }
            }
            
            // reset selection info
            for loc in self.selectedCells {
                self.game.gameBoard[loc.yLoc][loc.xLoc]._demagnify()
            }
            self.selectedCells.removeAll()
            self.keywordBuilder = ""
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
    
    //=========================== popups ===========================
    /**
     Congraturation popup. You won!
     One clickable option should be available: yummy -> main view
     the popup should not be dismissed upon clicking anywhere outside
     */
    struct YouBeatTheGame: View {
        var backButton: reset
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Winner Winner Chicken Dinner!")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                Button(action: {
                    self.backButton()
                }) {
                    Text("YUMMY")
                        .font(.system(size:30))
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }.padding(10)
            }.padding(30)
            .background(Color(#colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)))
            .shadow(radius: 5)
        }
    }
    
    /**
     User failed
     One clickable option should be available: retry -> main view
     the popup should not be dismissed upon clicking anywhere outside
     */
    struct YouDied: View {
        @ObservedObject var game: Game = Game.sharedInstance
        var backButton: reset
        
        var body: some View {
            VStack(spacing: 20) {
                Text("You Died!")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                Button(action: {
                    // restart the game
                    self.game.isRunning = true
                    self.game._resetGame()
                }) {
                    Text("RETRY")
                        .font(.system(size:30))
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }.padding(10)
            }.padding(30)
            .background(Color(#colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)))
            .shadow(radius: 5)
        }
    }
    
    //===============================================================

}
