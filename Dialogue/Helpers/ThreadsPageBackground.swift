//
//  ThreadsPageBackground.swift
//  Dialogue
//
//  Created by Porter Glines on 3/27/23.
//

import SwiftUI

struct ThreadsPageBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
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
                Circle().fill(Color("User"))
                    .blur(radius: 70)
                    .offset(x: 320, y: animate ? 100 : 80)
                    .animation(.easeInOut(duration: 10).repeatForever(), value: animate)
                    .scaleEffect(1.2)
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
                }
            }
        }
        .ignoresSafeArea()
        .brightness(colorScheme == .dark ? 0.0 : 0.0)
        .saturation(colorScheme == .dark ? 1.05 : 1.05)
    }
}
