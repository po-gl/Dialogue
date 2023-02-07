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
                                    .padding(.vertical, 10)
                                    .padding(.bottom, 10)
                                    .padding(.bottom, chat.endThread ? 15 : 0)
                                    .overlay(alignment: .bottom) { Rectangle().frame(height: 2).opacity(chat.endThread ? 1 : 0) }
                                    .padding(.bottom, chat.endThread ? 15 : -2)
                                    .padding(.bottom, chat.id == allChats.last!.id ? 100 + keyboardHeight : 0)
                                    .id(chat.id)
                        }
                        .onChange(of: allChats.count) { _ in
                            withAnimation { scroll.scrollTo(allChats.last?.id) }
                        }
                        .onChange(of: allChats.last?.endThread) { _ in
                            guard allChats.last?.endThread == true else { return }
                            withAnimation { scroll.scrollTo(allChats.last?.id) }
                        }
                        .onAppear {
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
    
    @ViewBuilder
    private func ChatDivider() -> some View {
        Rectangle()
            .frame(height: 2)
            .padding(.vertical, 15)
    }
}

