//
//  WordSearchTests.swift
//  WordSearchTests
//
//  Created by Marshall Lee on 2020-04-24.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI
import XCTest
@testable import WordSearch


var view: Game!

class WordSearchUITests: XCTestCase {
    
    override class func setUp() {
        view = Game.sharedInstance
        view._resetGame()
    }
    
    /**
    This validatees if the game is initialized properly with the right size of gameboard
     */
    func test_GameInit() throws {
        XCTAssertEqual(view.gameBoard.count, Game.boardSize)
        for row in 0..<view.gameBoard.count {
            XCTAssertEqual(view.gameBoard[row].count, Game.boardSize)
        }
    }
    
    /**
     This validates if the gameboard has all specs & requirements.
     not testing privates as I prefer a balckbox + monkey
     */
    func test_Game() throws {
         // must be at least 10x10
        XCTAssertEqual(Game.boardSize, 10)

        // game must include [java, kotlin, objectivec, vairable, swift, mobile]
        XCTAssertTrue(Game.keywordList.contains("JAVA"))
        XCTAssertTrue(Game.keywordList.contains("KOTLIN"))
        XCTAssertTrue(Game.keywordList.contains("OBJECTIVEC"))
        XCTAssertTrue(Game.keywordList.contains("VARIABLE"))
        XCTAssertTrue(Game.keywordList.contains("SWIFT"))
        XCTAssertTrue(Game.keywordList.contains("MOBILE"))
        
        // scan through gameboard, and searches for requried keywords
        // validate if keywordList is covered in the board
        XCTAssertTrue(_validateGame(game: view))
        
        // validate if game can reset
        var previousBoard: [Cell] = []
        // make lieaner
        for row in 0..<view.gameBoard.count {
            for cell in 0..<view.gameBoard[row].count {
                previousBoard.append(view.gameBoard[row][cell])
            }
        }
        view._resetGame()
        var postBoard: [Cell] = []
        for row in 0..<view.gameBoard.count {
            for cell in 0..<view.gameBoard[row].count {
                postBoard.append(view.gameBoard[row][cell])
            }
        }
        
        for index in 0..<postBoard.count {
            XCTAssertTrue(postBoard[index] != previousBoard[index])
        }
        
    }
    
    
    
    // ========== board scan helper ==========
    private func _validateGame(game: Game) -> Bool {
        var wordCounter: Int = 0
        var anchor: [Cell] = []
        
        // iterate through the keyword list
        for keyIndex in 0..<Game.keywordList.count {
            let currentKeyword: String = Game.keywordList[keyIndex]
            var isFound: Bool = false
            print("Finding: " + currentKeyword)
            
            // get the current cell
            var counter: Int = 0
            for  row in 0..<game.gameBoard.count {
                if isFound { break }
                
                for cell in 0..<game.gameBoard[row].count {
                    anchor.append(game.gameBoard[row][cell])
                    
                    isFound = __findWord(anchor: &anchor, keyword: currentKeyword)
                    counter += 1
                    print(currentKeyword + ": " + (isFound ? "Found: " + String(isFound) : String(isFound)) + " at " + String(counter))
                    
                    if isFound {
                        wordCounter += 1
                        break
                    } else {
                        // pass
                    }
                    anchor.removeAll()
                }
            }
        }
        print(wordCounter)
        return wordCounter == Game.keywordList.count
    }
    
    private func __findWord(anchor: inout [Cell], keyword: String) -> Bool {
        if anchor.count != 1 || anchor.first!.value! != String(keyword.first!) {
            return false
        }

        for dir in Game.Direction.allCases {
            for index in 0..<keyword.count {
                let nextLoc = view.getNextDirection(position: anchor.last!.location!, direction: dir)
                
                // bound check
                if nextLoc.yLoc >= 0 && nextLoc.yLoc < Game.boardSize &&
                    nextLoc.xLoc >= 0 && nextLoc.xLoc < Game.boardSize {
                    if view.gameBoard[nextLoc.yLoc][nextLoc.xLoc].value! == String(keyword[keyword.index(keyword.startIndex, offsetBy: index)]) {
                        anchor.append(view.gameBoard[nextLoc.yLoc][nextLoc.xLoc])
                        print(view.gameBoard[nextLoc.yLoc][nextLoc.xLoc].value!)
                    }
                } else {
                    continue
                }
            }
            var current: String = ""
            for i in 0..<anchor.count {
                current.append(anchor[i].value!)
            }
            print("-> " + current)
            if keyword == current {
                // correct
                return true
            } else {
                // nope, reset the anchor
                anchor = [anchor.first!]
            }
        }
        return false
    }
    // =======================================
}

