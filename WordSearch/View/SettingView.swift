//
//  SettingView.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-25.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    
    var body: some View {
        VStack {
            Button(action: {
                // change setting1
            }) {
                Text("setting1")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Button(action: {
                // change setting2
            }) {
                Text("setting2")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
    }
}
