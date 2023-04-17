//
//  ChatLog.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI
import Combine
import MarkdownUI
#if os(iOS)
import Introspect
#endif

struct ChatLog: View {
    @ObservedObject var chatThread: ChatThread
    private var allChats: [Chat] { chatThread.chatsArray }
    
    @State private var oldAllChatsCount: Int?
    @State private var lastID = ObjectIdentifier(Int.self)
    
    @State private var shouldScroll = false
    
    @State private var animate = false
    @State private var keyboardHeight: CGFloat = 0
    
    private let maxChats = 50
    
#if os(iOS)
    private let keyboardOffset: CGFloat = 140
#elseif os(OSX)
    private let keyboardOffset: CGFloat = 100
#endif
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    let allChats = allChats
                    if allChats.isEmpty { EmptyChat().padding(.top, 250) }
                    
                    VStack (spacing: 0){
                        if allChats.count > maxChats { RunoffIndicator() }
                        Chats(geometry)
                    }
                    
                    .onChange(of: self.allChats.count) { newCount in
                        if !wasChatRemoved() {
                            scrollToLastChat(scroll: scroll, withAnim: true)
                        }
                        oldAllChatsCount = newCount
                    }
                    .onChange(of: allChats.last?.endThread) { _ in
                        guard allChats.last?.endThread == true else { return }
                        scrollToLastChat(scroll: scroll, withAnim: true)
                    }
                    .onAppear {
                        scrollToLastChat(scroll: scroll, withAnim: false)
                    }
                    
                    .onChange(of: chatThread) { chatThread in
                        scrollToLastChat(scroll: scroll, withAnim: false)
                        Task {
                            try? await Task.sleep(for: .seconds(0.1))
                            shouldScroll = true
                        }
                    }
                    .onChange(of: shouldScroll) { shouldScroll in
                        guard shouldScroll else { return }
                        scrollToLastChat(scroll: scroll, withAnim: true)
                        self.shouldScroll = false
                    }
#if os(iOS)
                    .onReceive(Publishers.keyboardHeight) { height in
                        self.keyboardHeight = height == 0 ? 0 : height - 70
                    }
                    .onReceive(Publishers.keyboardOpened) { _ in
                        scrollToLastChat(scroll: scroll, withAnim: true)
                    }
#endif
                    .frame(width: geometry.size.width)
                    .onAppear {
                        animate = true
                        oldAllChatsCount = allChats.count
                    }
                }
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(stops: [.init(color: .white.opacity(0.8), location: 0.0), .init(color: .clear, location: 1.0)], startPoint: .top, endPoint: .bottom))
                        .blendMode(.softLight)
                        .allowsHitTesting(false)
                        // SwiftUI bug: blendmode flickers to normal if touching
                        // horizontal edges during navigation animations
                        .frame(width: max(geometry.size.width - 2, 0), height: max(geometry.size.height - 2, 0))
                )
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    
    @ViewBuilder
    private func Chats(_ geometry: GeometryProxy) -> some View {
        let allChats = allChats
        ForEach(allChats.dropFirst(max(allChats.count-maxChats, 0)), id: \Chat.id) { chat in
            ChatView(chat: chat, animate: animate, geometry: geometry)
                .padding(.vertical, 10)
                .padding(.bottom, 10)
            
                .padding(.bottom, chat.endThread ? 30 : 0)
                .overlay(alignment: .bottom) { ChatDivider(colorString: chat.endThreadDividerColor ?? "").opacity(chat.endThread ? 1 : 0).offset(y: 5) }
            
                .id(chat.id)
        }
        
        Color.clear.frame(height: keyboardOffset + keyboardHeight)
            .id(lastID)
    }
    
    @ViewBuilder
    private func RunoffIndicator() -> some View {
        Rectangle()
            .fill(LinearGradient(colors: [.primary.opacity(0.2), .primary], startPoint: .top, endPoint: .bottom))
            .frame(width: 30, height: 30)
            .mask {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .scaleEffect(1.5)
            }
            .padding(.top, 20)
    }
    
    private func scrollToLastChat(scroll: ScrollViewProxy, withAnim: Bool) {
        if withAnim {
#if os(iOS)
            withAnimation { scroll.scrollTo(lastID, anchor: .bottom) }
#elseif os(OSX)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { scroll.scrollTo(lastID, anchor: .bottom) }
            }
#endif
        } else {
            scroll.scrollTo(lastID, anchor: .bottom)
        }
    }
    
    private func wasChatRemoved() -> Bool {
        return oldAllChatsCount ?? 0 > allChats.count
    }
}

