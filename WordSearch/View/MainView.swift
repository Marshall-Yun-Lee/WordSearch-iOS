//
//  MainView.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-24.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI

struct MainView: View {
    // pre-declaring function type for each button
    typealias start = () -> Void

    // input to be initialized via caller
    var startFunction: start
    
    // Texts
    let titleCopy: String = "WORD SEARCH"
    let startCopy: String = "START"
    let settingCopy: String = "SETTING"
    
    @State var isSettingOpen: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // TITLE
            Text(titleCopy)
                .font(.system(size: 50))
                .foregroundColor(.white)
                .padding(.bottom, 40)
            
            // START
            Button(action: {
                self.startFunction()
            }) {
                Text(startCopy)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // SETTING
            Button(action: {
                self.isSettingOpen = true
            }) {
                Text(settingCopy)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }.sheet(isPresented: $isSettingOpen, content: { SettingView() })
        }
    }
    
    //============== Behaviours ==============
    
    //========================================
}
