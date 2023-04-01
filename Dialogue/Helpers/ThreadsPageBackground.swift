//
//  ThreadsPageBackground.swift
//  Dialogue
//
//  Created by Porter Glines on 3/27/23.
//

import SwiftUI

#if os(iOS)
struct ThreadsPageBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var animate = false
    
    
    var body: some View {
        ColorBlobs()
            .onAppear {
                withAnimation {
                    animate = true
                }
            }
    }
    
    @ViewBuilder
    private func ColorBlobs() -> some View{
        ZStack {
            VStack {
                Circle().fill(Color(hex: 0x6EED89))
                    .blur(radius: 70)
                    .offset(x: 320, y: animate ? 120 : 80)
                    .animation(.easeInOut(duration: 10).repeatForever(), value: animate)
                    .scaleEffect(1.2)
                    .brightness(0.13).saturation(1.1)
                Spacer()
            }
            
            VStack {
                Spacer()
                ZStack {
                    Circle().fill(Color("Server"))
                        .blur(radius: 50)
                        .offset(x: -50, y: 200)
                        .scaleEffect(0.9)
                    Circle().fill(Color("ServerAccent"))
                        .blur(radius: 50)
                        .offset(x: animate ? -30 : -130, y: animate ? 300 : 200)
                        .scaleEffect(0.9)
                        .animation(.easeInOut(duration: 8).repeatForever(), value: animate)
                    Circle().fill(Color("UserAccent"))
                        .blur(radius: 50)
                        .offset(x: -250, y: 100)
                    
                    Circle().fill(colorScheme == .dark ? Color("ServerAccent") : .black)
                        .blur(radius: 80)
                        .offset(x: -180, y: 230)
                        .opacity(colorScheme == .dark ? 0.5 : 0.1)
                    
                    Image("PickSpot")
                        .resizable()
                        .frame(width: 300, height: 300)
                        .scaleEffect(0.9)
                        .opacity(verticalSizeClass == .compact ? 0.0 : 0.8)
                        .offset(x: -170, y: 220)
                }
            }
        }
        .ignoresSafeArea()
        .brightness(colorScheme == .dark ? 0.0 : 0.0)
        .saturation(colorScheme == .dark ? 1.05 : 1.05)
    }
}
#endif
