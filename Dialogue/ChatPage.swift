//
//  ChatPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/4/23.
//

import SwiftUI

struct ChatPage: View {
    private let titleEmoji = ["🤖", "🔮", "🌞", "👁️"]
    @State private var waiting: Bool = false
    
    var body: some View {
#if os(iOS)
        iOSLayout()
#elseif os(OSX)
        MacOSLayout()
#endif
    }
    
    @ViewBuilder
    private func iOSLayout() -> some View {
        ZStack {
            Page()
            ToolbarView()
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color("Background"))
    }
    
    @ViewBuilder
    private func MacOSLayout() -> some View {
        NavigationStack {
            Page()
        }
        .toolbar {
            ToolbarView()
        }
        .navigationTitle("Dialogue \(titleEmoji.randomElement()!)")
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color("BackgroundMacOS"))
        .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
    }
    
    
    @ViewBuilder
    private func Page() -> some View {
        ZStack {
            ChatLog()
            VStack (spacing: 0) {
                Spacer()
                if waiting {
                    WaitingIndicator()
                        .padding(.bottom, 5)
                }
                AskView(waiting: $waiting)
            }
        }
    }
}
