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
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    VStack (spacing: 0) {
                        ForEach(allChats, id: \.id) { chat in
                            ChatView(chat: chat, geometry: geometry)
                                .padding(.top, 10)
                                .padding(.bottom, chat.id == allChats.last!.id ? 80 + keyboardHeight : 10)
                                .id(chat.id)
                        }
                        .onChange(of: allChats.count) { _ in
                            withAnimation { scroll.scrollTo(allChats.last?.id) }
                        }
                        .onAppear() {
                            scroll.scrollTo(allChats.last?.id)
                        }
                        .onReceive(Publishers.keyboardHeight) { height in
                            self.keyboardHeight = height == 0 ? 0 : height - 30
                        }
                        .onReceive(Publishers.keyboardOpened) { _ in
                            withAnimation { scroll.scrollTo(allChats.last?.id) }
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    
}

