//
//  Color+isDark.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import Foundation
import SwiftUI

#if os(iOS)
extension UIColor {
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}

extension Color {
    var isDarkColor : Bool {
        return UIColor(self).isDarkColor
    }
}
#elseif os(OSX)
extension NSColor {
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        let ciColor = CIColor(color: self)!
        r = ciColor.red
        g = ciColor.green
        b = ciColor.blue
        a = ciColor.alpha
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}
extension Color {
    var isDarkColor : Bool {
        return NSColor(self).isDarkColor
    }
}
#endif
