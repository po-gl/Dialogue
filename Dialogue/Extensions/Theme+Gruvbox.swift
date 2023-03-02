//
//  Theme+Gruvbox.swift
//  Dialogue
//
//  Created by Porter Glines on 3/2/23.
//

import Foundation
import Splash

#if os(iOS)
import UIKit
private typealias Color = UIColor
#elseif os(macOS)
private typealias Color = NSColor
#endif

public extension Splash.Theme {
    static func gruvLight(withFont font: Splash.Font) -> Theme {
        return Theme(
            font: font,
            plainTextColor: Color(
                red: 61/255,
                green: 59/255,
                blue: 71/255,
                alpha: 1.0
            ),
            tokenColors: [ // Light mode colors
                .keyword:   Color(red: 204/255, green:  36/255, blue:  29/255, alpha: 1.0), // purple
                .string:    Color(red: 121/255, green: 116/255, blue:  14/255, alpha: 1.0), // green
                .type:      Color(red: 181/255, green: 118/255, blue:  20/255, alpha: 1.0), // yellow
                .call:      Color(red:  70/255, green: 132/255, blue:  72/255, alpha: 1.0), // aqua (darkened)
                .number:    Color(red: 143/255, green:  63/255, blue: 113/255, alpha: 1.0), // purple
                .comment:   Color(red: 146/255, green: 141/255, blue: 116/255, alpha: 1.0), // gray
                .property:  Color(red:   7/255, green: 102/255, blue: 120/255, alpha: 1.0), // blue
                .dotAccess: Color(red:  69/255, green: 133/255, blue: 136/255, alpha: 1.0), // light blue
                .preprocessing: Color(red: 175/255, green: 58/255, blue: 3/255, alpha: 1.0)
            ],
            backgroundColor: Color(
                red: 0.098,
                green: 0.098,
                blue: 0.098,
                alpha: 1.0
            )
        )
    }
}
