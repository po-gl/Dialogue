//
//  ChatView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI
import MarkdownUI
import Splash
import LinkPresentation


struct ChatView: View {
    var chat: Chat
    @State var animate: Bool
    var geometry: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    private var color: SwiftUI.Color { chat.fromUser ? SwiftUI.Color("User") : SwiftUI.Color("Server") }
    private var colorAccent: SwiftUI.Color { chat.fromUser ? SwiftUI.Color("UserAccent") : Color("ServerAccent") }
    
    @State var spotOffset: Double = Double.random(in: 45..<60)
    
    private var maxWidth: Double { chat.fromUser ? geometry.size.width - geometry.size.width/4 : geometry.size.width - geometry.size.width/13 }
    private var alignment: Alignment { chat.fromUser ? .bottomTrailing : .bottomLeading }
    private var oppositeAlignment: Alignment { chat.fromUser ? .bottomLeading : .bottomTrailing }
    
    @State var isPresentingDeleteConfirm = false
    
    @State var isPresentingDeletePairConfirm = false
    @State var pairChat: Chat?
    
    var body: some View {
        if !chat.isFault {
            ChatMessage()
                .animation(.interpolatingSpring(stiffness: 250, damping: 26), value: animate)
                .onAppear {
                    animate = false
                }
                .confirmationDialog("Are you sure?", isPresented: $isPresentingDeleteConfirm) {
                    Button("Delete message", role: .destructive) {
                        basicHaptic()
                        withAnimation { ChatData.deleteChat(chat, context: viewContext)}
                        ChatThreadData.wasEdited(chat.thread!, context: viewContext)
                    }
                }
                .confirmationDialog("Are you sure?", isPresented: $isPresentingDeletePairConfirm) {
                    let message = pairChat != nil ? "Delete pair of messages" : "Delete message (no pair found)"
                    Button(message, role: .destructive) {
                        basicHaptic()
                        withAnimation {
                            ChatData.deleteChat(chat, context: viewContext)
                            if let pairChat {
                                ChatData.deleteChat(pairChat, context: viewContext)
                            }
                        }
                        ChatThreadData.wasEdited(chat.thread!, context: viewContext)
                    }
                }
        } else {
            Rectangle().fill(.clear)
        }
    }
    
    
    @ViewBuilder
    private func ChatMessage() -> some View {
        VStack (alignment: alignment.horizontal) {
            ZStack (alignment: alignment) {
                ChatBody()
#if os(iOS)
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20))
#endif
                    .compositingGroup()
                    .contextMenu { ChatContextMenu() }
                Bubble()
                    .offset(x: chat.fromUser ? 8 : -8, y: 8)
            }
            .padding(.horizontal)
        }
        .offset(y: animate ? 0 : 20)
        .frame(maxWidth: maxWidth, alignment: Alignment(horizontal: alignment.horizontal, vertical: .center))
        .frame(width: geometry.size.width, alignment: Alignment(horizontal: alignment.horizontal, vertical: .center))
    }
    
    
    @ViewBuilder
    private func ChatBody() -> some View {
        VStack (alignment: alignment.horizontal, spacing: 5) {
            ChatMarkdown()
            Timestamp()
        }
        .padding([.top, .horizontal])
        .padding(.bottom, 10)
        .background(RoundedRectangle(cornerRadius: 20).fill(color))
        
        .overlay(alignment: oppositeAlignment) { Image("PickSpotSmall").resizable().frame(width: 100, height: 100).offset(x: chat.fromUser ? -50 : 50, y: spotOffset).opacity(0.6) }
        
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color("Outline"), lineWidth: 2))
        
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .clipped()
    }
    
    @ViewBuilder
    private func Timestamp() -> some View {
        Text(chat.timestamp!, formatter: chat.text!.count > 15 ? timeFormatter : shortTimeFormatter)
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(color.isDarkColor ? .white : .black)
            .opacity(chat.text!.count > 8 ? 0.5 : 0.0)
            .frame(maxHeight: chat.text!.count > 8 ? 12 : 0.0)
    }
    
    @ViewBuilder
    private func Bubble() -> some View {
        BubbleAccent(fromUser: chat.fromUser,
                     useLoopingGradient: abs(chat.timestamp!.timeIntervalSinceNow) < 60*60*3)
    }
    
    
    @ViewBuilder
    private func ChatMarkdown() -> some View {
        Markdown(chat.text!)
            .markdownTextStyle() {
                ForegroundColor(color.isDarkColor ? .white : .black)
            }
        
            .markdownTextStyle(\.emphasis) {
                FontStyle(.italic)
            }
            .markdownTextStyle(\.strong) {
                FontWeight(.heavy)
            }
            .markdownTextStyle(\.link) {
                ForegroundColor(Color(hex: 0x076678))
            }
        
            .markdownCodeSyntaxHighlighter(.splash(theme: .gruvLight(withFont: .init(size: 16))))
            .markdownBlockStyle(\.codeBlock) { configuration in
                configuration.label
                    .overlay(alignment: .topTrailing) {
                        CopyCodeButton(code: configuration.content)
                            .scaleEffect(0.8)
                            .opacity(0.4)
                    }
            }
#if os(OSX)
            .textSelection(.enabled)
#endif
    }
    
    
    
    @ViewBuilder
    private func ChatContextMenu() -> some View {
        Button(action: {
            basicHaptic()
            saveToClipboard(text: chat.text)
        }) {
            Label("Copy", systemImage: "doc.on.doc")
        }
        
        Button(action: {
            basicHaptic()
            withAnimation {
                ChatData.toggleEndThread(chat: chat, context: viewContext)
                ChatThreadData.wasEdited(chat.thread!, context: viewContext)
            }
        }) {
            Label(chat.endThread ? "Open Thread" : "Close Thread", systemImage: "circle.and.line.horizontal")
        }
        
        Button(role: .destructive, action: {
            basicHaptic()
            isPresentingDeleteConfirm = true
        }) {
            Label("Remove", systemImage: "trash")
        }
        
        Button(role: .destructive, action: {
            basicHaptic()
            Task {
                pairChat = await ChatData.fetchPair(for: chat)
                isPresentingDeletePairConfirm = true
            }
        }) {
            Label("Remove Pair", systemImage: "trash")
        }
    }
    
    private func check() -> Bool {
        print("Check called!")
        return true
    }
}


private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

private let shortTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Wrapper(fromUser: true).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            Wrapper(fromUser: false).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
    
    struct Wrapper: View {
        var fromUser: Bool
        @Environment(\.managedObjectContext) private var viewContext
        @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .reverse)])
        private var allChats: FetchedResults<Chat>
        private var lastChat: Chat { return allChats[fromUser ? 0 : 1] }
        
        var body: some View {
            GeometryReader { geometry in
                ChatView(chat: lastChat, animate: true, geometry: geometry)
            }
        }
    }
}
