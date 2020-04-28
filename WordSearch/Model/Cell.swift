
//
//  Cell.swift
//  WordSearch
//
//  Created by Marshall Lee on 2020-04-24.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import SwiftUI


struct Cell: Hashable, View {
    static let scale: CGFloat = _getFrameSize()
    
    var value: String?
    let location: Location?
    var isSelected: Bool = false
    
    var body: some View {
        // tried make them buttons with InstantClick(); didn't work
        ZStack {
            Rectangle()
                .fill(self.isSelected ? Color.red : Color.white)
                .frame(width: Cell.scale, height: Cell.scale, alignment: .center)
                .border(self.isSelected ? Color.red : Color.black)
            Text(self.value ?? "?")
                .font(.system(size: 25))
                .foregroundColor(.black)
        }
    }
    
    
    public mutating func _toggleSelect() {
        self.isSelected.toggle()
    }
    
    // Equatable
    // ignoring selection toggle
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.value == rhs.value && lhs.location == rhs.location
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(location)
        hasher.combine(isSelected)
    }
}

/*
 calculate each cell square' size.
 - horizontal padding: 20
 - board size: 10
 */
func _getFrameSize() -> CGFloat {
    let sidePadding: CGFloat = 10 * 2
    let numCell: CGFloat = 10
    return (UIScreen.main.bounds.width - sidePadding) / numCell
}

// meh
struct InstantClick: PrimitiveButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration
        .label
        .onLongPressGesture (
            minimumDuration: 0,
            perform: configuration.trigger
        )
    }
}
