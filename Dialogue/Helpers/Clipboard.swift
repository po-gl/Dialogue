//
//  Clipboard.swift
//  Dialogue
//
//  Created by Porter Glines on 4/17/23.
//

import SwiftUI
    
public func saveToClipboard(text: String?) {
#if os(iOS)
    UIPasteboard.general.string = text
#elseif os(OSX)
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text ?? "", forType: .string)
#endif
}
