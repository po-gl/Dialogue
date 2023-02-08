//
//  ChatView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI

struct ChatView: View {
    var chat: Chat
    var geometry: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    private var color: Color { return chat.fromUser ? Color("User") : Color("Server") }
    private var colorAccent: Color { return chat.fromUser ? Color("UserAccent") : Color("ServerAccent") }
    private var maxWidth: Double { return chat.fromUser ? geometry.size.width - geometry.size.width/4 : geometry.size.width - geometry.size.width/9 }
    
    
    var body: some View {
        VStack {
            ZStack (alignment: chat.fromUser ? .bottomTrailing : .bottomLeading) {
                ChatText()
                    .contextMenu { ChatContextMenu() }
                Bubble()
                    .offset(x: chat.fromUser ? 8 : -8, y: 8)
            }
            .padding(.horizontal)
            .frame(maxWidth: maxWidth,
                   alignment: chat.fromUser ? .trailing : .leading)
        }
        .frame(width: geometry.size.width, alignment: chat.fromUser ? .trailing : .leading)
    }
    
    @ViewBuilder
    private func ChatText() -> some View {
        VStack (alignment: chat.fromUser ? .trailing : .leading ,spacing: 5) {
            Text("\(chat.text!)")
            Text("\(chat.timestamp!, formatter: timeFormatter)")
                .font(.system(size: 12, design: .monospaced))
                .opacity(0.5)
        }
        .foregroundColor(color.isDarkColor ? .white : .black)
        .padding([.top, .horizontal])
        .padding(.bottom, 10)
        .background(RoundedRectangle(cornerRadius: 20).fill(color))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color("Outline"), lineWidth: 2))
    }
    
    @ViewBuilder
    private func Bubble() -> some View {
        Circle()
            .fill(colorAccent)
            .overlay(Circle().stroke(Color("Outline"), lineWidth: 2))
            .frame(width: 12, height: 12)
    }
    
    @ViewBuilder
    private func ChatContextMenu() -> some View {
        Button(action: {
            UIPasteboard.general.string = chat.text
        }) {
            Label("Copy", systemImage: "doc.on.doc")
        }
        Button(action: deleteChat) {
            Label("Remove", systemImage: "trash")
        }
    }
    
    private func deleteChat() {
        viewContext.delete(chat)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
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
                ChatView(chat: lastChat, geometry: geometry)
            }
        }
    }
}
