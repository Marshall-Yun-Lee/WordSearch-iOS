//
//  Highlight.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-26.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI

struct Highlight: View {
    
    var body: some View {
        
        Capsule()
        .size(width: 100, height: 100)
            .scale(x: 100, y: 100, anchor: UnitPoint.center)

        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                }
                .onEnded { _ in
                  //
                }
        )
    }
}
