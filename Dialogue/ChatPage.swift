//
//  ChatPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/4/23.
//

import SwiftUI
import Introspect

struct ChatPage: View {
    @Environment(\.colorScheme) private var colorScheme
    
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
            .introspectNavigationController { navController in
                let appearence = UINavigationBarAppearance()
                appearence.backgroundColor = .clear
                appearence.backgroundEffect = .none
                navController.navigationBar.standardAppearance = appearence
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Background"))
            .overlay(alignment: .top) {
                StatusBarBlur()
            }
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
    
    
    @ViewBuilder
    private func StatusBarBlur() -> some View {
        Color.clear
            .background(.ultraThinMaterial)
            .brightness(colorScheme == .dark ? -0.1 : 0.02)
            .edgesIgnoringSafeArea(.top)
            .frame(height: 0)
    }
}
