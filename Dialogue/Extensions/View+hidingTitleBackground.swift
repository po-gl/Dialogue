//
//  View+hidingTitleBackground.swift
//  Dialogue
//
//  Created by Porter Glines on 5/27/23.
//

import SwiftUI

extension View {
    func hidingTitleBackground() -> some View {
        ModifiedContent(content: self, modifier: HidingTitleBackground())
    }
}

struct HidingTitleBackground : ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showing = true
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: geometry.frame(in: .named("titleScroll")).origin)
                }
            )
            .onPreferenceChange(ScrollOffsetKey.self) { scrollPos in
                showing = scrollPos.y < 100
            }
            .overlay(alignment: .top) {
                StatusBarBlur()
                    .opacity(showing ? 1.0 : 0.0)
            }
    }
    
    @ViewBuilder
    private func StatusBarBlur() -> some View {
        Color.clear
            .background(.ultraThinMaterial)
            .brightness(colorScheme == .dark ? -0.1 : 0.02)
            .edgesIgnoringSafeArea(.top)
            .frame(height: 0)
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}
