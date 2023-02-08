//
//  Color+Adjust.swift
//  Dialogue
//
//  Created by Porter Glines on 2/8/23.
//

import SwiftUI

#if os(iOS)
extension Color {
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return Color(uiColor: UIColor(self).lighter(by: percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return Color(uiColor: UIColor(self).darker(by: percentage))
    }
}

extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: min(r + percentage/100, 1.0),
                       green: min(g + percentage/100, 1.0),
                       blue: min(b + percentage/100, 1.0),
                       alpha: a)
    }
}
#elseif os(OSX)

extension Color {
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return Color(NSColor: NSColor(self).lighter(by: percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return Color(NSColor: NSColor(self).darker(by: percentage))
    }
}

extension NSColor {
    func lighter(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> NSColor {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return NSColor(red: min(r + percentage/100, 1.0),
                       green: min(g + percentage/100, 1.0),
                       blue: min(b + percentage/100, 1.0),
                       alpha: a)
    }
}
#endif
