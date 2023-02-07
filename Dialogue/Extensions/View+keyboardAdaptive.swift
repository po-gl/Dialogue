//
//  View+keyboardAdaptive.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI
import Combine

extension View {
    func keyboardAdaptive(minus padding: Double = 0) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive(padding: padding))
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var paddingToSubtract: Double = 0
    
    var padding: Double
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .padding(.bottom, paddingToSubtract)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
            .onReceive(Publishers.keyboardReadable) { self.paddingToSubtract = $0 ? padding : 0 }
    }
}


extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
    
    static var keyboardReadable: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

