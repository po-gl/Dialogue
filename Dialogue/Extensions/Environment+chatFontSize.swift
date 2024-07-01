//
//  Environment+chatFontSize.swift
//  Dialogue
//
//  Created by Porter Glines on 6/30/24.
//

import SwiftUI

private struct ChatFontSizeKey: EnvironmentKey {
    static let defaultValue: Binding<CGFloat> = .constant(14.0)
}

extension EnvironmentValues {
    var chatFontSize: Binding<CGFloat> {
        get { self[ChatFontSizeKey.self] }
        set { self[ChatFontSizeKey.self] = newValue }
    }
}
