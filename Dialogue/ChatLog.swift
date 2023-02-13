//
//  ChatLog.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI
import Combine

struct ChatLog: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .forward)])
    private var allChats: FetchedResults<Chat>
    
    @State private var keyboardHeight: CGFloat = 0
    
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    if allChats.isEmpty {
                        EmptyChat()
                            .padding(.top, 250)
                    }
                    LazyVStack (spacing: 0){
                        Chats(geometry)
                    }
                    .onChange(of: allChats.count) { _ in
                        scrollToLastChat(scroll: scroll)
                    }
                    .onChange(of: allChats.last?.endThread) { _ in
                        guard allChats.last?.endThread == true else { return }
                        scrollToLastChat(scroll: scroll)
                    }
                    .onAppear {
                        scroll.scrollTo(allChats.last?.id)
                    }
#if os(iOS)
                    .onReceive(Publishers.keyboardHeight) { height in
                        self.keyboardHeight = height == 0 ? 0 : height - 30
                    }
                    .onReceive(Publishers.keyboardOpened) { _ in
                        scrollToLastChat(scroll: scroll)
                    }
#endif
                    .frame(width: geometry.size.width)
                    .onAppear {
                        animate = true
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    
    @ViewBuilder
    private func Chats(_ geometry: GeometryProxy) -> some View {
        ForEach(allChats, id: \.id) { chat in
            ChatView(chat: chat, animate: animate, geometry: geometry)
                .padding(.vertical, 10)
                .padding(.bottom, 10)
            
                .padding(.bottom, chat.endThread ? 30 : 0)
                .overlay(alignment: .bottom) { ChatDivider(colorString: chat.endThreadDividerColor ?? "").opacity(chat.endThread ? 1 : 0).offset(y: 5) }
            
                .padding(.bottom, chat.id == allChats.last!.id ? 130 + keyboardHeight : 0)
                .id(chat.id)
        }
    }
    
    private func scrollToLastChat(scroll: ScrollViewProxy) {
        #if os(iOS)
        withAnimation { scroll.scrollTo(allChats.last?.id) }
        #elseif os(OSX)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation { scroll.scrollTo(allChats.last?.id) }
        }
        #endif
    }
}

