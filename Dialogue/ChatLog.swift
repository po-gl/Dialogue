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
    @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .forward)])
    private var allChats: FetchedResults<Chat>
    @State private var oldAllChatsCount: Int?
    
    @State private var animate = false
    @State private var keyboardHeight: CGFloat = 0
    
    private let maxChats = 50
    private var hasRunoff: Bool { allChats.count > maxChats }
    
#if os(iOS)
    private let keyboardOffset: CGFloat = 45
#elseif os(OSX)
    private let keyboardOffset: CGFloat = 100
#endif
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    if allChats.isEmpty {
                        EmptyChat().padding(.top, 250)
                    }
                    VStack (spacing: 0){
                        if hasRunoff { RunoffIndicator() }
                        Chats(geometry)
                    }
                    .onChange(of: allChats.count) { _ in
                        if !wasChatRemoved() {
                            scrollToLastChat(scroll: scroll)
                        }
                        oldAllChatsCount = allChats.count
                    }
                    .onChange(of: allChats.last?.endThread) { _ in
                        guard allChats.last?.endThread == true else { return }
                        scrollToLastChat(scroll: scroll)
                    }
                    .onAppear {
                        scroll.scrollTo(allChats.last?.id, anchor: .bottom)
                    }
#if os(iOS)
                    .onReceive(Publishers.keyboardHeight) { height in
                        self.keyboardHeight = height == 0 ? 0 : height - 70
                    }
                    .onReceive(Publishers.keyboardOpened) { _ in
                        scrollToLastChat(scroll: scroll)
                    }
                    .padding(.bottom, 95)
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
                )
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    
    @ViewBuilder
    private func Chats(_ geometry: GeometryProxy) -> some View {
        ForEach(allChats.dropFirst(max(allChats.count-maxChats, 0)), id: \.id) { chat in
            ChatView(chat: chat, animate: animate, geometry: geometry)
                .padding(.vertical, 10)
                .padding(.bottom, 10)
            
                .padding(.bottom, chat.endThread ? 30 : 0)
                .overlay(alignment: .bottom) { ChatDivider(colorString: chat.endThreadDividerColor ?? "").opacity(chat.endThread ? 1 : 0).offset(y: 5) }
            
                .padding(.bottom, chat.id == allChats.last!.id ? keyboardOffset + keyboardHeight : 0)
                .id(chat.id)
        }
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
    
    private func scrollToLastChat(scroll: ScrollViewProxy) {
        #if os(iOS)
        withAnimation { scroll.scrollTo(allChats.last?.id, anchor: .bottom) }
        #elseif os(OSX)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation { scroll.scrollTo(allChats.last?.id, anchor: .bottom) }
        }
        #endif
    }
    
    private func wasChatRemoved() -> Bool {
        return oldAllChatsCount ?? 0 > allChats.count
    }
}

