//
//  ChatPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/4/23.
//

import SwiftUI
import Introspect

struct ChatPage: View {
    private let titleEmoji = ["🤖", "🔮", "🌞", "👁️"]
    @State private var waiting: Bool = false
    
    var chatThread: ChatThread
    
    var body: some View {
        Page()
            .toolbar {
                ChatsToolbarView(chatThread: chatThread)
            }
            .navigationTitle("Dialogue \(titleEmoji.randomElement()!)")
            .ignoresSafeArea(.container, edges: .bottom)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Background"))
#elseif os(OSX)
            .background(Color("BackgroundMacOS"))
            .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
#endif
    }
    
    
    @ViewBuilder
    private func Page() -> some View {
        ZStack {
            ChatLog(chatThread: chatThread)
            VStack (spacing: 0) {
                Spacer()
                if waiting {
                    WaitingIndicator()
                        .padding(.bottom, 5)
                }
                AskView(chatThread: chatThread, waiting: $waiting)
            }
        }
    }
}
