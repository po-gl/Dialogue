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
    
    @ObservedObject var apiRequestHandler = ChatRequestHandler()
    @State private var inputText: String = ""
    @Binding var waiting: Bool
    
    private let askPhrases = ["How", "Why", "What", "Who", "Nothing", "Anything", "Something"]
    
#if os(iOS)
    private let toggleButtonFontSize: Double = 26
    private let chatTextPadding: Double = 11
    private let borderWidth: Double = 1
    @State private var bottomPadding: Double = 40
#elseif os(OSX)
    private let toggleButtonFontSize: Double = 20
    private let chatTextPadding: Double = 7
    private let borderWidth: Double = 1
    
    @FocusState private var focus: Bool
#endif
    
    var body: some View {
        HStack {
            ToggleThreadButton()
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
#endif
    }
    
    @ViewBuilder
    private func ToggleThreadButton() -> some View {
        let gradient = LinearGradient(stops: [.init(color: Color("Server"), location: -0.2),
                                              .init(color: Color("ServerAccent"), location: 0.6),
                                              .init(color: .black, location: 1.6)],
                                      startPoint: .top, endPoint: .bottom)
        
        Button(action: toggleEndThread) {
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
    }
    
    private func toggleEndThread() {
        guard allChats.count > 0 else { return }
        completeHaptic()
        withAnimation(.interpolatingSpring(stiffness: 170, damping: 10)) {
            allChats.last!.endThread.toggle()
            if allChats.last!.endThread {
                allChats.last!.endThreadDividerColor = ChatDivider.colors.randomElement()
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    @ViewBuilder
    private func ChatInput() -> some View {
        TextField("Ask ChatGPT \(askPhrases.randomElement()!.lowercased())...", text: $inputText, axis: .vertical)
            .textFieldStyle(.plain)
            .tint(Color("ServerAccent"))
            .padding(chatTextPadding)
#if os(OSX)
            .padding(.horizontal, 5)
            .focused($focus)
            .onAppear {
                focus = true
            }
            .onSubmit {
                sendRequest()
            }
            .touchBar {
                ToggleThreadButton()
                    .padding(20)
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
    
    
    private func sendRequest() {
        guard inputText != "" else { return }
        basicHaptic()
        withAnimation { waiting = true }
        Task {
            await self.apiRequestHandler.makeRequest(texts: getLastCoupleChats())
            handleResponse()
            withAnimation { waiting = false }
        }
        addUserChat()
        inputText = ""
    }
    
    private func handleResponse() {
        completeHaptic()
        if let data = apiRequestHandler.responseData {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let choices = json["choices"] as? [[String: Any]] {
                    if let text = choices[0]["text"] as? String {
                        print("Response: \(String(reflecting: text))")
                        addServerChat(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else {
                    addServerChat("There was an error processing the request, try again.")
                }
            }
        }
    }
    
    
    private func getLastCoupleChats() -> [String] {
        var texts: [String] = []
        for i in 0..<Int(messageMemory)+1 {
            guard allChats.endIndex-1 - i >= 0 else { break }
            let chat = allChats[allChats.endIndex-1 - i]
            
            if chat.endThread { break }
            texts.append(chat.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        }
        return texts
    }
    
    
    private func addUserChat() {
        withAnimation {
            let newChat = Chat(context: viewContext)
            newChat.timestamp = Date()
            newChat.text = "\(inputText)"
            newChat.fromUser = true

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("CoreData error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addServerChat(_ text: String) {
        withAnimation {
            let newChat = Chat(context: viewContext)
            newChat.timestamp = Date()
            newChat.text = "\(text)"
            newChat.fromUser = false

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("CoreData error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

