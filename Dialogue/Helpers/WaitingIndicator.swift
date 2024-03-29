//
//  WaitingIndicator.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI

struct WaitingIndicator: View {
    
    private var duration: Double = 1.3
    
    private var width: Double = 45
    
    var colors: [Color] {
        [
            Color("Server"),
            Color("ServerAccent"),
            Color(hex: 0xA02A95),
            Color(hex: 0x331F99),
            Color(hex: 0x476FEE),
            Color(hex: 0xA9ECF1),
            
            Color(hex: 0xaC537A),
            Color("UserAccent"),
            Color(hex: 0xE3AC53),
            Color(hex: 0x72DFF6),
            Color("User"),
        ]
    }
    
    @State var animate = false
    
    var body: some View {
        HStack (spacing: 4) {
            DotView(delay: 0.0,        duration: duration)
            DotView(delay: duration/2, duration: duration)
            DotView(delay: duration,   duration: duration)
        }
        .padding(.vertical, 6.3)
        .frame(width: width)
        
        .background(GradientBackground()
            .mask(RoundedRectangle(cornerRadius: 30)))
        .overlay(RoundedRectangle(cornerRadius: 30).strokeBorder(Color("Outline"), lineWidth: 1.7))
        .onAppear { animate = true }
    }
    
    @ViewBuilder
    private func GradientBackground() -> some View {
        LinearGradient(colors: colors.prefix(colors.count-1) + colors.reversed().prefix(colors.count-1) + colors, startPoint: .leading, endPoint: .trailing)
            .scaleEffect(x: 4.0)
            // - 15 to adjust for animation misalignment
            .offset(x: animate ? -width*2 + width/2: width*2 - width/2 - 15)
            .animation(.linear(duration: duration*40).repeatForever(autoreverses: false), value: animate)
            .scaleEffect(x: 2)
    }
    
    
    struct DotView: View {
        var delay: Double = 0
        var duration: Double
        @State var opacity: Double = -0.15
        var body: some View {
            Circle()
                .frame(width: 6.5)
                .opacity(opacity)
                .animation(.easeInOut(duration: duration).repeatForever().delay(delay), value: opacity)
                .onAppear {
                    self.opacity = 0.8
                }
        }
    }
}


struct WaitingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView()
    }
    
    private struct WrapperView: View {
        @State var showWaiting = true
        
        var body: some View {
            VStack {
                if showWaiting {
                    WaitingIndicator()
//                        .opacity(showWaiting ? 1.0 : 0.0)
                }
                
                Button(showWaiting ? "Hide" : "Show") {
                    withAnimation { showWaiting.toggle() }
                }
            }
            
        }
    }
}
