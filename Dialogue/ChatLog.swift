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
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    VStack (spacing: 0) {
                        ForEach(allChats, id: \.id) { chat in
                            ChatView(chat: chat, geometry: geometry)
                                .padding(.top, 10)
                                .padding(.bottom, chat.id == allChats.last!.id ? 80 : 10)
                                .id(chat.id)
                                .if(chat.id == allChats.last!.id) { view in
                                    view.keyboardAdaptive(minus: -40)
                                }
                        }
                        .onChange(of: allChats.count) { _ in
                            withAnimation {
                                scroll.scrollTo(allChats.last?.id, anchor: .bottom)
                            }
                        }
                        .onAppear() {
                            scroll.scrollTo(allChats.last?.id)
                        }
                        .onReceive(Publishers.keyboardOpened) { _ in
                            withAnimation {
                                scroll.scrollTo(allChats.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

