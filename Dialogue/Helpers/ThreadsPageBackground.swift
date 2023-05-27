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
    
    @State private var hueAnimate = false
    
    var body: some View {
        ColorBlobs()
            .onAppear {
                hueAnimate = true
            }
    }
    
    @ViewBuilder
    private func ColorBlobs() -> some View{
        VStack {
            Spacer()
            ZStack {
                Circle().fill(Color(hex: 0x6EED89))
                    .overlay(SoftLightCircleOverlay())
                    .blur(radius: 70)
                    .offset(x: 240, y: 120)
                    .scaleEffect(1.2)
                    .brightness(0.13).saturation(1.1)

                Circle().fill(Color("Server"))
                    .overlay(SoftLightCircleOverlay())
                    .blur(radius: 50)
                    .offset(x: -50, y: 180)
                    .scaleEffect(0.9)
                Circle().fill(Color(hex: 0xF03B2E))
                    .overlay(SoftLightCircleOverlay())
                    .blur(radius: 50)
                    .offset(x: 60, y: 280)
                    .scaleEffect(0.9)
                Circle().fill(Color(hex: 0xec3377))
                    .overlay(SoftLightCircleOverlay())
                    .offset(x: -250, y: 180)
                    .blur(radius: 50)
                
                Circle().fill(Color(hex: 0x201944))
//                    .overlay(SoftLightCircleOverlay())
                    .blur(radius: 70)
                    .scaleEffect(x: 5, y: 0.7)
                    .offset(x: -60, y: 300)
                
            }
        }
        .ignoresSafeArea()
        .brightness(colorScheme == .dark ? 0.0 : 0.0)
        .saturation(colorScheme == .dark ? 1.05 : 1.05)
    }
    
    @ViewBuilder
    private func SoftLightCircleOverlay() -> some View {
        LinearGradient(stops:
                        [.init(color: .clear, location: 0.8),
                         .init(color: .white.opacity(0.8), location: 1.0)],
                       startPoint: .bottom, endPoint: .top)
            .blendMode(.softLight)
            .clipShape(Circle())
    }
}
#endif
