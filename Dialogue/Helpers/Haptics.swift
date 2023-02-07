//
//  Haptics.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

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
