//
//  WordListview.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-28.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI

struct WordListView: View {
    var body: some View {
        
    ZStack {
        VStack(spacing: 60) {
            Text("WORD LIST")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Text("Swift")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Kotlin")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            
                Text("ObjectiveC")
                    .font(.system(size: 40))
                    .foregroundColor(.white)

                Text("Variable")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Java")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Mobile")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                }
            }
        }
    }
}
