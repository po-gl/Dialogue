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
                                    .overlay(alignment: .bottom) { ChatDivider().opacity(chat.endThread ? 1 : 0) }
                                    .padding(.bottom, chat.endThread ? 15 : -5)
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
        let onTop = false // Bool.random()
        let gradientLength: Double = 35
        
        let topGradient = LinearGradient(stops: [
            .init(color: Color("Background"), location: 0.0),
            .init(color: Color("User"), location: 1.0)
        ], startPoint: .top, endPoint: .bottom)
        
        let bottomStops: [Gradient.Stop] = Bool.random() ? [
            .init(color: Color("Server"), location: 0.0),
            .init(color: Color("ServerAccent").opacity(0.6), location: 0.4),
            .init(color: Color("Background"), location: 1.0)
        ] : [
            .init(color: Color("User"), location: 0.0),
            .init(color: Color("ServerAccent").opacity(0.3), location: 0.7),
            .init(color: Color("Background"), location: 1.0)
        ]
        let bottomGradient = LinearGradient(stops: bottomStops, startPoint: .top, endPoint: .bottom)
        
        VStack (spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .scaleEffect(x: 1, y: gradientLength, anchor: .bottom)
                .opacity(onTop ? 1 : 0)
                .foregroundStyle(topGradient)
            Rectangle()
                .frame(height: 3)
                .foregroundColor(Color("Outline"))
            Rectangle()
                .frame(height: 1)
                .scaleEffect(x: 1, y: gradientLength, anchor: .top)
                .opacity(onTop ? 0 : 1)
                .foregroundStyle(bottomGradient)
        }
            .frame(height: 5)
    }
}

