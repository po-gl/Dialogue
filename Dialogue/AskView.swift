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
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .forward)])
    private var allChats: FetchedResults<Chat>
    
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
#elseif os(OSX)
    private let toggleButtonFontSize: Double = 20
    private let chatTextPadding: Double = 7
    private let borderWidth: Double = 1
    
#endif
    @FocusState private var focus: Bool
    
    var body: some View {
        HStack (alignment: .bottom) {
            ToggleThreadButton()
                .padding(.bottom, 7)
            HStack (alignment: .bottom) {
                ChatInput()
#if os(iOS)
                SendButton()
                    .padding(.bottom, 4)
#endif
            }
            .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(colorScheme == .dark ? Color("Gray") : .black, style: StrokeStyle(lineWidth: borderWidth)).opacity(0.5))
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
#if os(OSX)
        .padding(.top, 5)
        .padding([.trailing, .bottom], 10)
        .background(Rectangle().fill(.ultraThinMaterial).brightness(colorScheme == .dark ? -0.03 : 0.012))
#elseif os(iOS)
        .padding(.bottom, bottomPadding)
        .onReceive(Publishers.keyboardReadable) { opened in
            withAnimation {
                bottomPadding = opened ? 0 : 40
            }
        }
        .background(Rectangle().fill(.ultraThinMaterial).brightness(colorScheme == .dark ? -0.1 : 0.012))
        
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
                ChatData.toggleEndThread(chat: allChats.last!, context: viewContext)
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
        .buttonStyle(.plain)
#if os(iOS)
        .alwaysPopover(isPresented: $showThreadButtonHint) {
            Text("??? This button ends the thread. You can use it to **restart the conversation.**")
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
        let gradient = LinearGradient(stops: [.init(color: Color("Server"), location: -0.4),
                                              .init(color: Color("ServerAccent"), location: 1.0)],
                                      startPoint: .top, endPoint: .bottom)
        Button(action: sendRequest) {
            Image(systemName: "arrow.up")
                .resizable()
                .frame(width: 17, height: 20)
        }
        .buttonStyle(PopStyle(color: Color("ServerAccent"), gradient: gradient, radius: 50))
        .frame(width: 35, height: 35)
        .padding(.trailing, 5)
    }
    
    
// MARK: Send Request functions
    
    private func sendRequest() {
        guard inputText != "" else { return }
        basicHaptic()
        withAnimation { waiting = true }
        Task {
            await self.apiRequestHandler.makeRequest(chats: getLastCoupleChats())
            handleResponse()
            withAnimation { waiting = false }
        }
        withAnimation { ChatData.addUserChat(inputText, context: viewContext) }
        inputText = ""
    }
    
    private func handleResponse() {
        completeHaptic()
        let responseText = ChatRequestHandler.getResponseString(apiRequestHandler.responseData)
        withAnimation { ChatData.addServerChat(responseText, context: viewContext) }
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

