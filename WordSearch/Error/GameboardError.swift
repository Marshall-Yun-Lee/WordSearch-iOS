//
//  GameboardError.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-25.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

// enum for possible exceptions in GameView manipulation
enum GameboardError: Error {
    case LengthyKeyword
    case KeywordNotEnglishAlphabet
    case BoardOutBound
}
