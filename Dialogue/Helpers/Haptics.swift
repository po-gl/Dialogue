//
//  Haptics.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

#if os(iOS)
import UIKit

public func basicHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}

public func completeHaptic() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
    let generator2 = UIImpactFeedbackGenerator(style: .heavy)
    generator2.impactOccurred()
}
#elseif os(OSX)
public func basicHaptic() {
    
}

public func completeHaptic() {
    
}
#endif
