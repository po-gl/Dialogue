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
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\ChatThread.lastEdited, order: .reverse)])
    private var chatThreads: FetchedResults<ChatThread>
    
    private let titleEmoji = ["🤖", "🔮", "🌞", "👁️"]
    @State private var waiting: Bool = false
    
    @Binding var chatThread: ChatThread
    
    
    var body: some View {
        Page()
            .toolbar {
                ChatsToolbarView(chatThread: chatThread)
            }
        
            .ignoresSafeArea(.container, edges: .bottom)
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SwipeTitle()
                }
            }
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
            .navigationTitle(chatThread.name ?? "New Thread \(titleEmoji.randomElement()!)")
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
    private func SwipeTitle() -> some View {
        Menu {
            ForEach(chatThreads) { thread in
                if chatThread != thread {
                    Button(action: { withAnimation { chatThread = thread } }) {
                        Text(thread.name ?? "New Thread \(titleEmoji.randomElement()!)")
                    }
                }
            }
        } label: {
            Text(chatThread.name ?? "New Thread \(titleEmoji.randomElement()!)")
        }
        .tint(.primary)
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
