//
//  PopStyle.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import Foundation
import SwiftUI

struct PopStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    var color: Color
    var gradient: LinearGradient?
    var radius = 30.0
    
    func makeBody(configuration: Configuration) -> some View {
        if let gradient {
            RoundedRectangle(cornerRadius: radius)
                .foregroundStyle(gradient)
                .overlay(RoundedRectangle(cornerRadius: radius).stroke(colorScheme == .dark ? .clear : .black, lineWidth: 2))
                .overlay(configuration.label.foregroundColor(color.isDarkColor ? .white : .black))
                .opacity(configuration.isPressed ? 0.4 : 1.0)
        } else {
            RoundedRectangle(cornerRadius: radius)
                .foregroundColor(color)
                .overlay(RoundedRectangle(cornerRadius: radius).stroke(colorScheme == .dark ? .clear : .black, lineWidth: 2))
                .overlay(configuration.label.foregroundColor(color.isDarkColor ? .white : .black))
                .opacity(configuration.isPressed ? 0.4 : 1.0)
        }
    }
}
