//
//  AskView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI
import Combine

struct AskView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    var chatThread: ChatThread
    private var allChats: [Chat] { chatThread.chatsArray }
    
    @AppStorage("messageMemory") private var messageMemory: Double = 2
    @AppStorage("showThreadButtonHint") private var showThreadButtonHint = true
    
    @ObservedObject var apiRequestHandler = ChatRequestHandler()
    @State private var inputText: String = ""
    @Binding var waiting: Bool
    
    private let askPhrases = ["How", "Why", "What", "Who", "Anything", "Something"]
    
#if os(iOS)
    private let toggleButtonFontSize: Double = 26
    private let chatTextPadding: Double = 11
    private let borderWidth: Double = 1
    @State private var bottomPadding: Double = 40
    private let materialDarkBrightness = -0.1
#elseif os(OSX)
    private let toggleButtonFontSize: Double = 20
    private let chatTextPadding: Double = 7
    private let borderWidth: Double = 1
    private let materialDarkBrightness = -0.03
    
#endif
    @FocusState private var focus: Bool
    
    var body: some View {
        HStack (alignment: .bottom) {
            ToggleThreadButton()
                .padding(.bottom, 7)
            HStack (alignment: .bottom) {
                ChatInput()
                SendButton()
                    .padding(.bottom, 4)
            }
            .background(RoundedRectangle(cornerRadius: 26).fill(.ultraThinMaterial).opacity(0.3).brightness(colorScheme == .dark ? materialDarkBrightness : 0.012))
            .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(.primary, style: StrokeStyle(lineWidth: borderWidth)).opacity(0.4))
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
#if os(OSX)
        .padding(.top, 5)
        .padding([.trailing, .bottom], 10)
#elseif os(iOS)
        .padding(.bottom, bottomPadding)
        .onReceive(Publishers.keyboardReadable) { opened in
            withAnimation {
                bottomPadding = opened ? 0 : 40
            }
        }
        
        .simultaneousGesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onEnded { value in
                if value.translation.height > 0 {
                    focus = false
                }
                if value.translation.height < 0 {
                    focus = true
                }
            }
        )
#endif
        .background(Rectangle().fill(.ultraThinMaterial).brightness(colorScheme == .dark ? materialDarkBrightness : 0.012))
    }
    
    @ViewBuilder
    private func ToggleThreadButton() -> some View {
        let gradient = LinearGradient(stops: [.init(color: Color("Server"), location: -0.2),
                                              .init(color: Color("ServerAccent"), location: 0.6),
                                              .init(color: .black, location: 1.6)],
                                      startPoint: .top, endPoint: .bottom)
        Button(action: {
            guard allChats.count > 0 else { return }
            completeHaptic()
            withAnimation(.interpolatingSpring(stiffness: 170, damping: 10)) {
                if let lastChat = allChats.last {
                    ChatData.toggleEndThread(chat: lastChat, context: viewContext)
                    ChatThreadData.wasEdited(chatThread, context: viewContext)
                }
            }
        }) {
            Image(systemName: "circle.and.line.horizontal.fill")
                .foregroundColor(Color("ServerAccent"))
                .font(.system(size: toggleButtonFontSize))
                .overlay(
                    Rectangle()
                        .fill(gradient)
                        .blendMode(.softLight)
                        .mask {
                            Image(systemName: "circle.and.line.horizontal.fill")
                                .foregroundColor(Color("ServerAccent"))
                                .font(.system(size: toggleButtonFontSize))
                        }
                )
        }
        .keyboardShortcut("k")
        .buttonStyle(.plain)
#if os(iOS)
        .alwaysPopover(isPresented: $showThreadButtonHint) {
            Text("✨ This button ends the thread. You can use it to **restart the conversation.**")
                .font(.system(size: 16))
                .frame(width: 160)
                .padding()
        }
#endif
        .simultaneousGesture(LongPressGesture().onEnded({ _ in showThreadButtonHint = true }))
    }
    
    
    @ViewBuilder
    private func ChatInput() -> some View {
        TextField("Ask ChatGPT \(askPhrases.randomElement()!.lowercased())...", text: $inputText, axis: .vertical)
            .textFieldStyle(.plain)
            .tint(Color("ServerAccent"))
            .padding(chatTextPadding)
            .focused($focus)
#if os(OSX)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .onAppear {
                focus = true
            }
            .onSubmit {
                sendRequest()
            }
            .touchBar {
                ToggleThreadButton()
                    .padding(.horizontal, 20)
            }
#endif
    }
    
    @ViewBuilder
    private func SendButton() -> some View {
#if os(iOS)
        let diameter: Double = 35
#elseif os(OSX)
        let diameter: Double = 25
#endif
        let arrowWidth: Double = 17
        let arrowHeight: Double = 20
        let gradient = LinearGradient(stops: [.init(color: Color("Server"), location: -0.4),
                                              .init(color: Color("ServerAccent"), location: 1.0)],
                                      startPoint: .top, endPoint: .bottom)
        Button(action: sendRequest) {
            Image(systemName: "arrow.up")
                .resizable()
#if os(iOS)
                .frame(width: arrowWidth, height: arrowHeight)
#elseif os(OSX)
                .frame(width: arrowWidth * 0.65, height: arrowHeight * 0.65)
#endif
        }
        .buttonStyle(PopStyle(color: Color("ServerAccent"), gradient: gradient, radius: 50))
        .frame(width: diameter, height: diameter)
        .padding(.trailing, 5)
    }
    
    
// MARK: Send Request functions
    
    private func sendRequest() {
        guard inputText != "" else { return }
        basicHaptic()
        withAnimation { ChatData.addUserChat(inputText, thread: chatThread, context: viewContext) }
        ChatThreadData.wasEdited(chatThread, context: viewContext)
        
        withAnimation { waiting = true }
        Task {
            await self.apiRequestHandler.makeRequest(chats: getLastCoupleChats())
            handleResponse()
            withAnimation { waiting = false }
        }
        inputText = ""
    }
    
    private func handleResponse() {
        completeHaptic()
        let responseText = ChatRequestHandler.getResponseString(apiRequestHandler.responseData)
        withAnimation { ChatData.addServerChat(responseText, thread: chatThread, context: viewContext) }
        ChatThreadData.wasEdited(chatThread, context: viewContext)
    }
    
    
    private func getLastCoupleChats() -> [[String: String]] {
        var texts: [[String: String]] = []
        for i in 0..<Int(messageMemory)+1 {
            guard allChats.endIndex-1 - i >= 0 else { break }
            let chat = allChats[allChats.endIndex-1 - i]
            
            if chat.endThread { break }
            
            if let text = chat.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let role = chat.fromUser ? "user" : "assistant"
                texts.append(["role" : role, "content" : text])
            }
        }
        return texts.reversed()
    }
}

