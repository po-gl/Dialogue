//
//  WaitingIndicator.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI

struct WaitingIndicator: View {
    
    var body: some View {
        HStack (spacing: 5) {
            DotView()
            DotView(delay: 0.4)
            DotView(delay: 0.8)
        }
        .foregroundColor(Color("Gray"))
    }
    
    
    struct DotView: View {
        var delay: Double = 0
        @State var opacity: Double = 1
        var body: some View {
            Circle()
                .frame(width: 10)
                .opacity(opacity)
                .animation(.easeInOut(duration: 1.0).repeatForever().delay(delay), value: opacity)
                .onAppear {
                    self.opacity = 0.0
                }
        }
    }
}


struct WaitingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        WaitingIndicator()
    }
}
