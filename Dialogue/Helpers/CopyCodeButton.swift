//
//  CopyCodeButton.swift
//  Dialogue
//
//  Created by Porter Glines on 4/17/23.
//

import SwiftUI

struct CopyCodeButton: View {
    var code: String
    
    @State var showCheck = false
    
    var body: some View {
        Button(action: {
            completeHaptic()
            saveToClipboard(text: code)
            withAnimation { showCheck = true }
            Task { try? await Task.sleep(for: .seconds(3.0))
                withAnimation { showCheck = false }
            }
        }) {
            Image(systemName: showCheck ? "checkmark.circle" : "doc.on.doc")
                .scaleEffect(showCheck ? 1.15 : 1.0)
                .offset(y: showCheck ? 3 : 0)
        }
#if os(OSX)
        .offset(x: 25)
        .buttonStyle(.plain)
        .animation(.easeInOut, value: showCheck)
#endif
    }
}

struct CopyCodeButton_Previews: PreviewProvider {
    static var previews: some View {
        CopyCodeButton(code: "print(\"Hello code\")")
    }
}
