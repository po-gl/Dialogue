//
//  WaitingIndicator.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI

struct WaitingIndicator: View {
    
    private var duration: Double = 0.7
    
    var body: some View {
        HStack (spacing: 5) {
            DotView(delay: 0.0,        duration: duration)
            DotView(delay: duration/2, duration: duration)
            DotView(delay: duration,   duration: duration)
        }
        .foregroundColor(Color("Gray"))
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 30).foregroundStyle(.ultraThinMaterial))
    }
    
    
    struct DotView: View {
        var delay: Double = 0
        var duration: Double
        @State var opacity: Double = 0.1
        var body: some View {
            Circle()
                .frame(width: 10)
                .opacity(opacity)
                .animation(.easeInOut(duration: duration).repeatForever().delay(delay), value: opacity)
                .onAppear {
                    self.opacity = 0.8
                }
        }
    }
}


struct WaitingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView()
    }
    
    private struct WrapperView: View {
        @State var showWaiting = false
        
        var body: some View {
            VStack {
                if showWaiting {
                    WaitingIndicator()
//                        .opacity(showWaiting ? 1.0 : 0.0)
                }
                
                Button(showWaiting ? "Hide" : "Show") {
                    withAnimation { showWaiting.toggle() }
                }
            }
            
        }
    }
}
