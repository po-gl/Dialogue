//
//  ChatDivider.swift
//  Dialogue
//
//  Created by Porter Glines on 2/8/23.
//

import SwiftUI

struct ChatDivider: View {
    public var colorString: String
    
    static var colors = ["UserStyle", "ServerStyle"]
    
    var onTop = false
    var gradientLength: Double = 35
    
    let topGradient = LinearGradient(stops: [
        .init(color: .clear, location: 0.0),
        .init(color: Color("User"), location: 1.0)
    ], startPoint: .top, endPoint: .bottom)
    
    var bottomStops: [Gradient.Stop] {
        switch colorString {
        case ChatDivider.colors[1]:
            return [ .init(color: Color("User"), location: 0.0),
                     .init(color: Color("UserAccent").opacity(0.2), location: 0.8),
                     .init(color: .clear, location: 1.0) ]
        default:
            return [ .init(color: Color("Server"), location: -0.1),
                     .init(color: Color("ServerAccent").opacity(0.6), location: 0.4),
                     .init(color: .clear, location: 1.0) ]
        }
    }
    
    var body: some View {
        let bottomGradient = LinearGradient(stops: bottomStops, startPoint: .top, endPoint: .bottom)
        
        VStack (spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .scaleEffect(x: 1, y: gradientLength, anchor: .bottom)
                .opacity(onTop ? 1 : 0)
                .foregroundStyle(topGradient)
                .brightness(0.10)
                .saturation(1.15)
            Rectangle()
                .frame(height: 3)
                .foregroundColor(Color("Outline"))
            Rectangle()
                .frame(height: 1)
                .scaleEffect(x: 1, y: gradientLength, anchor: .top)
                .opacity(onTop ? 0 : 1)
                .foregroundStyle(bottomGradient)
                .brightness(0.10)
                .saturation(1.15)
        }
            .frame(height: 5)
    }
}
