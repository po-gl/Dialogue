//
//  ChatView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI
import MarkdownUI
import Splash


struct ChatView: View {
    var chat: Chat
    @State var animate: Bool
    var geometry: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    private var color: SwiftUI.Color { return chat.fromUser ? SwiftUI.Color("User") : SwiftUI.Color("Server") }
    private var colorAccent: SwiftUI.Color { return chat.fromUser ? SwiftUI.Color("UserAccent") : Color("ServerAccent") }
    private var maxWidth: Double { return chat.fromUser ? geometry.size.width - geometry.size.width/4 : geometry.size.width - geometry.size.width/13 }
    
    
    var body: some View {
        ChatMessage()
            .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: animate)
            .onAppear {
                animate = false
            }
#if os(iOS)
            .fixContextFlicker()
#endif
    }
    
    
    @ViewBuilder
    private func ChatMessage() -> some View {
        VStack {
            ZStack (alignment: chat.fromUser ? .bottomTrailing : .bottomLeading) {
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
            .frame(maxWidth: maxWidth, alignment: chat.fromUser ? .trailing : .leading)
            .offset(y: animate ? 0 : 20)
        }
        .frame(width: geometry.size.width, alignment: chat.fromUser ? .trailing : .leading)
    }
    
    
    @ViewBuilder
    private func ChatBody() -> some View {
        VStack (alignment: chat.fromUser ? .trailing : .leading ,spacing: 5) {
            ChatMarkdown()
#if os(OSX)
                .textSelection(.enabled)
#endif
            Timestamp()
        }
        .padding([.top, .horizontal])
        .padding(.bottom, 10)
        .background(RoundedRectangle(cornerRadius: 20).fill(color))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color("Outline"), lineWidth: 2))
    }
    
    @ViewBuilder
    private func Timestamp() -> some View {
        if chat.text!.count > 8 {
            Text("\(chat.timestamp!, formatter: chat.text!.count > 15 ? timeFormatter : shortTimeFormatter)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(color.isDarkColor ? .white : .black)
                .opacity(0.5)
        } else {
            Rectangle().fill(.clear).frame(width: 0, height: 0)
        }
    }
    
    @ViewBuilder
    private func Bubble() -> some View {
        Circle()
            .fill(colorAccent)
            .overlay(Circle().stroke(Color("Outline"), lineWidth: 2))
            .frame(width: 12, height: 12)
    }
    
    
    @ViewBuilder
    private func ChatMarkdown() -> some View {
        Markdown("\(chat.text!)")
            .markdownTextStyle() {
                ForegroundColor(color.isDarkColor ? .white : .black)
            }
            .markdownCodeSyntaxHighlighter(.splash(theme: .gruvLight(withFont: .init(size: 16))))
    }
    
    
    
    @ViewBuilder
    private func ChatContextMenu() -> some View {
        Button(action: {
            basicHaptic()
            saveToClipboard()
        }) {
            Label("Copy", systemImage: "doc.on.doc")
        }
        Button(action: toggleEndThread) {
            Label(chat.endThread ? "Open Thread" : "Close Thread", systemImage: "circle.and.line.horizontal")
        }
        Button(role: .destructive, action: deleteChat) {
            Label("Remove", systemImage: "trash")
        }
    }
    
    private func saveToClipboard() {
#if os(iOS)
        UIPasteboard.general.string = chat.text
#elseif os(OSX)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(chat.text!, forType: .string)
#endif
    }
    
    private func deleteChat() {
        basicHaptic()
        withAnimation {
            viewContext.delete(chat)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func toggleEndThread() {
        basicHaptic()
        withAnimation {
            chat.endThread.toggle()
            if chat.endThread {
                chat.endThreadDividerColor = ChatDivider.colors.randomElement()
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
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
