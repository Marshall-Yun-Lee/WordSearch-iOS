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
    let settingCopy: String = "CREDIT"
    
    @State var isSettingOpen: Bool = false
    let screenBounds = UIScreen.main.bounds
    var body: some View {
        VStack(spacing: 20) {
            // TITLE
            Text(self.titleCopy)
                .font(.system(size: screenBounds.width * 0.1)) // scale to screen size
                .foregroundColor(.white)
                .padding(.bottom, 40)
            
            // START
            Button(action: {
                self.startFunction()
            }) {
                Text(self.startCopy)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // SETTING
            Button(action: {
                self.isSettingOpen = true
            }) {
                Text(self.settingCopy)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }.sheet(isPresented: self.$isSettingOpen, content: { SettingView() })
        }
    }
    
    //============== Behaviours ==============
    
    //========================================
}
