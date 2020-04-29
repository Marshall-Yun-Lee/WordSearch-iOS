
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
    public var isMagnified: Bool = false
    public var isSelected: Bool = false
    var isAnswered: Bool = false
    
    // providing a unique id to prevent dups dictionary key issue
    let id: UUID = UUID()

    
    var body: some View {
        // tried make them buttons with InstantClick(); didn't work
        ZStack {
            Rectangle()
                .fill(self.isSelected || self.isAnswered ? Color.red : Color.white)
                .frame(width: Cell.scale, height: Cell.scale, alignment: .center)
                .border(self.isSelected || self.isAnswered ? Color.red : Color.black)
            Text(self.value ?? "?")
                .font(.system(size: 25))
                .foregroundColor(.black)
        }.scaleEffect(isMagnified ? 1.2 : 1)
            .animation(.easeInOut)
    }
    
    // ============ getters ============
    public func getIsSelected() -> Bool {
        return isSelected
    }
    // =================================
    
    
    // =========== mutatings ===========
    public mutating func _select() -> Void {
        self.isSelected = true
    }
    public mutating func _deselect() -> Void {
        self.isSelected = false
    }
    
    public mutating func _magnify() -> Void {
        self.isMagnified = true
    }
    public mutating func _demagnify() -> Void {
        self.isMagnified = false
    }
    
    // should never be undo if user gets the correct answer
    public mutating func _answered() -> Void {
        self.isAnswered = true
    }
    // =================================
    
    
    
    // Equatable
    // ignoring selection toggle
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.id == rhs.id && lhs.location == rhs.location && lhs.isSelected == rhs.isSelected && lhs.value == rhs.value &&
            lhs.isAnswered == rhs.isAnswered && lhs.isMagnified == rhs.isMagnified
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(Cell.scale)
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
