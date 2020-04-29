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
        
        ZStack {
            VStack(spacing: 40) {
                Button(action: {
                    // change setting1
                }) {
                    Text("Marshall Yunseok Lee")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    let email = "contact@marshallyunseoklee.com"
                    
                    if let url = URL(string: "mailto:\(email)") {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("SEND EMAIL")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
