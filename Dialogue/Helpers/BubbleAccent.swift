//
//  BubbleAccent.swift
//  Dialogue
//
//  Created by Porter Glines on 4/8/23.
//

import SwiftUI

struct BubbleAccent: View {
#if os(OSX)
    @Environment(\.controlActiveState) private var controlActiveState
#endif
    
    var fromUser: Bool
    var useLoopingGradient: Bool
    
    var width: Double = 12
    var animationDuration: Double { fromUser ? 4 : 5}
    
    @State var animate = true
    
    var colors: [Color] {
        fromUser ?
        [Color(hex: 0xaC537A), Color("UserAccent"), Color(hex: 0xE3AC53), Color(hex: 0x72DFF6), Color("User"), Color(hex: 0xDDEEF7)] :
        [Color("Server"), Color("ServerAccent"), Color(hex: 0xA02A95), Color(hex: 0x331F99), Color(hex: 0x476FEE), Color(hex: 0xA9ECF1)]
    }
    
    var color: Color { fromUser ? Color("UserAccent") : Color("ServerAccent") }
    
    private var isFocusedWindow: Bool {
#if os(OSX)
        controlActiveState == .key
#elseif os(iOS)
        true
#endif
    }
    
    
    var body: some View {
        if useLoopingGradient && isFocusedWindow {
            GradientBubble()
        } else {
            Circle()
                .fill(color.gradient)
                .overlay(Circle().stroke(Color("Outline"), lineWidth: 1.3))
                .frame(width: width, height: width)
        }
    }
        
    @ViewBuilder
    private func GradientBubble() -> some View {
        GradientBackground()
            .mask(Circle())
            .overlay(Circle().stroke(Color("Outline"), lineWidth: 1.3))
            .frame(width: width, height: width)
        
            .onAppear {
                Task {
                    try? await Task.sleep(for: .seconds(0.1))
                    animate = false
                }
            }
            .onDisappear {
                animate = true
            }
    }
    
    @ViewBuilder
    private func GradientBackground() -> some View {
        LinearGradient(colors: colors + colors.reversed() + colors, startPoint: .leading, endPoint: .trailing)
            .scaleEffect(x: 4.0)
            // + 2 to adjust for animation misalignment
            .offset(x: animate ? -width*2 + width/2 + 2 : width*2 - width/2)
            .animation(.linear(duration: animationDuration).repeatForever(autoreverses: false), value: animate)
    }
}

struct BubbleAccent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BubbleAccent(fromUser: false, useLoopingGradient: true)
            BubbleAccent(fromUser: true, useLoopingGradient: true)
        }
        .scaleEffect(7)
    }
}
