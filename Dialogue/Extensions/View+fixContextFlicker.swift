//
//  View+fixContextFlicker.swift
//  Dialogue
//
//  Created by Porter Glines on 2/10/23.
//

import SwiftUI

extension View {
    func fixContextFlicker() -> some View {
        ModifiedContent(content: self, modifier: FixContextFlicker())
    }
}

struct FixContextFlicker: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .background {
                content
            }
    }
}
