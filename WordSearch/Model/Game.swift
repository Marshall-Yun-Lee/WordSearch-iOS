//
//  Game.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-27.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI

class Game: ObservableObject {
    // singleton
    static let sharedInstance = Game.init()
    private init() {
        self.gameBoard = _initializeBoard()
        self.score = 0
    }
    
    // static
    static let boardSize: Int = 10 // 10x10 board
    static let keywordList: [String] = [
        "SWIFT",
        "KOTLIN",
        "OBJECTIVEC",
        "VARIABLE",
        "JAVA",
        "MOBILE"
    ]
    
    // use getters
    private var reservedLocations: [Location] = []
    private var keywordsFound: [String] = []
    private var hintCount: Int = 5
    
    // props
    @Published var isRunning: Bool = false
    @Published var isEnd: Bool = false
    @Published var isDead: Bool = false
    @Published var gameBoard: [[Cell]] = []
    @Published var score: Int = 0
    @Published var timeRemaining = 60
    
    
    // mutating functions -- public
    /*
     This returns a 2D list of Cells based on boardSize variable
     Default board size is 10
    */
    public func _initializeBoard() -> [[Cell]] {
        var temp: [Cell] = [Cell] (repeating: Cell(value: "?", location: Location(yLoc: 0, xLoc: 0)), count: Game.boardSize)
        var out: [[Cell]] = [[Cell]] (repeating: temp, count: Game.boardSize)
        
        // y axis filling
        for yAxis in 0..<Game.boardSize {
            // x axis filling
            for xAxis in 0..<Game.boardSize {
                temp[xAxis] = Cell(value: __randomAlphabetGenerator(), location: Location(yLoc: yAxis, xLoc: xAxis))
            }
            out[yAxis] = temp
        }
        
        __injectKeyword(to: &out) // pass by ref
        return out
    }
    
    public func _resetGame() -> Void {
        self.reservedLocations.removeAll()
        self.keywordsFound.removeAll()
        self.score = 0
        self.hintCount = 5
        self.isEnd = false
        self.isDead = false
        self.timeRemaining = 60
        self.gameBoard.removeAll(keepingCapacity: false)
        self.gameBoard = _initializeBoard()
    }
    
    public func _showMeTheHint() -> Void {
        while self.hintCount > 0 {
            let randomPos: Location = self.reservedLocations.randomElement()!
            
            if !self.gameBoard[randomPos.yLoc][randomPos.xLoc].isAnswered {
                self.gameBoard[randomPos.yLoc][randomPos.xLoc].isAnswered = true
                break;
            }
            // continue
        }
        self.hintCount -= self.hintCount > 0 ? 1 : 0
    }
    
    
    //======================= getters =======================
    // not adding _ to getters as it is essential+general+noone knows what this is
    public func getReservedLocations() -> [Location] {
        return self.reservedLocations
    }
    
    public func getKeywordsFound() -> [String] {
        return self.keywordsFound
    }
    
    public func getHintCount() -> Int {
        return self.hintCount
    }
    
    public func getNextDirection(position: Location, direction: Direction) -> Location {
        switch direction {
        case .N:    return Location(yLoc: position.yLoc - 1, xLoc: position.xLoc)
        case .E:    return Location(yLoc: position.yLoc,     xLoc: position.xLoc + 1)
        case .S:    return Location(yLoc: position.yLoc + 1, xLoc: position.xLoc)
        case .W:    return Location(yLoc: position.yLoc,     xLoc: position.xLoc - 1)
        }
    }
    //=======================================================
    
    
    //====================== setters ========================
    public func _addKeywordsFound(keywords: String) -> Void {
        self.keywordsFound.append(keywords)
    }
    //=======================================================
    

    //================= initializer helpers =================
    /*
     This generates a string with a random upper-case English alphabet character
     A unicode based generator would look better though
     */
    private func __randomAlphabetGenerator() -> String {
        let chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<1).map{ _ in chars.randomElement()! })
    }

    // This inserts keywords to the game board in a random position
    private func __injectKeyword(to: inout [[Cell]]) -> Void {
        for current in 0..<Game.keywordList.count {
            let currentKeyword = Game.keywordList[current]
            var cellLocation: Location = Location(yLoc: 0, xLoc: 0)
            var isInjected: Bool = false
           
            while !isInjected {
                // initialize cell location to start
                do {
                    try cellLocation = __randomStartingPoint(keyword: currentKeyword)
                } catch GameboardError.LengthyKeyword {
                    print("Keyword too long")
                    continue // skip this index
                } catch GameboardError.KeywordNotEnglishAlphabet {
                    print("Keyword contains non-uppercase alphabet")
                    continue // skip this index
                } catch GameboardError.BoardOutBound {
                    print("unable to locate the starting point in the gameboard")
                    continue // skip this index
                } catch {
                    print("Unexpected error: \(error).")
                    continue // skip this index
                }
            
                // Get random direction to locate the keyword, and validate
                // If the position is validated after scanning, iterate through the keyword and replace the cells
                // Shuffling enum iteration to add more 'randomness'
                for dir in Direction.allCases.shuffled() {
                    if __scanDirection(board: to, keyword: currentKeyword, position: cellLocation, direction: dir) {
                        // inject
                        for char in currentKeyword {
                            // replace current location with the new value from the keyword
                            to[cellLocation.yLoc][cellLocation.xLoc] = Cell(value: String(char),
                                                                            location: Location(yLoc: cellLocation.yLoc, xLoc: cellLocation.xLoc),
                                                                            isSelected: false, isAnswered: false)
                            
                            // add this cellLocation to the reserved location list
                            self.reservedLocations.append(cellLocation)
                            
                            // update cellLocation for the next iteration based on the direction
                            cellLocation = getNextDirection(position: cellLocation, direction: dir)
                        }
                        isInjected = true
                        break // stop Direction enum iteration
                    }
                }
            }
        }
    }

    /*
     This validates the given keyword, and throws GameboardErrors:
     - lengthyKeywoard
     - KeywordNotUpperCaseAlphabet
     
     This picks a random starting point for the given String to locate in the gameboard
     */
    private func __randomStartingPoint(keyword: String) throws -> Location {
        guard keyword.count <= Game.boardSize else {
            throw GameboardError.LengthyKeyword
        }
        guard __isValidString(word: keyword) else {
            throw GameboardError.KeywordNotEnglishAlphabet
        }
        
        /*
        In this case, the keyword MUST be located at an edge:
        0[0][random] || 1[random][0] || 2[random][boardSize-1] || 3[boardSize-1][random]
        */
        if (keyword.count == Game.boardSize) {
            let randomEdge = Int.random(in: 0...3)
            switch randomEdge {
            case 0: return Location(yLoc: 0, xLoc: Int.random(in: 0..<Game.boardSize))                           // top edge
            case 1: return Location(yLoc: Int.random(in: 0..<Game.boardSize), xLoc: 0)                           // left edge
            case 2: return Location(yLoc: Int.random(in: 0..<Game.boardSize), xLoc: Game.boardSize - 1)    // right edge
            case 3: return Location(yLoc: Game.boardSize - 1, xLoc: Int.random(in: 0..<Game.boardSize))    // bottom edge
            default:
                throw GameboardError.BoardOutBound
            }
        }
         
        // randomized starting point
        return Location(yLoc: Int.random(in: 0 ..< Game.boardSize), xLoc: Int.random(in: 0 ..< Game.boardSize))
    }

    // This scan a direction and return true if the given keyword can fit into the position towards the given direction
    private func __scanDirection(board: [[Cell]], keyword: String, position: Location, direction: Direction) -> Bool {
        var currP = position
        for char in 0..<keyword.count {
            if currP.yLoc < 0 || currP.yLoc > Game.boardSize - 1 ||
                currP.xLoc < 0 || currP.xLoc > Game.boardSize - 1 ||
                (self.reservedLocations.contains(currP) && (board[currP.yLoc][currP.yLoc].value!.uppercased() != String(char).uppercased())) {
                return false
            }
            currP = getNextDirection(position: currP, direction: direction)
        }
        return true
    }

    // This validate if the given word is ONLY consisted of upper-case alphabets
    private func __isValidString(word: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if word.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        return true
    }

    // decided not to user crossing directions as it is not intuitive to drag on square cells
    enum Direction: CaseIterable {
        case N
        case E
        case S
        case W
    }
    //=======================================================


}

