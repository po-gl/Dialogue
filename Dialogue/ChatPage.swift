//
//  ChatPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/4/23.
//

import SwiftUI
import Introspect
import CoreData

struct ChatPage: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\ChatThread.lastEdited, order: .reverse)])
    private var chatThreads: FetchedResults<ChatThread>
    
    private let titleEmoji = ["🤖", "🔮", "🌞", "👁️"]
    @State private var waiting: Bool = false
    
    @State var chatThread: ChatThread
    
    init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
        if let thread = try? context.existingObject(with: objectID) as? ChatThread {
            _chatThread = State(initialValue: thread)
        } else {
            _chatThread = State(initialValue: ChatThread(context: context))
        }
    }
    
    
    var body: some View {
        Page()
            .toolbar {
                ChatsToolbarView(chatThread: chatThread)
            }
        
            .ignoresSafeArea(.container, edges: .bottom)
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SwipeTitle()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Background"))
            .overlay(alignment: .top) {
                StatusBarBlur()
            }
#elseif os(OSX)
            .navigationTitle(chatThread.name ?? "New Thread \(titleEmoji.randomElement()!)")
            .background(Color("BackgroundMacOS"))
            .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
#endif
    }
    
    
    @ViewBuilder
    private func Page() -> some View {
        ZStack {
            ChatLog(chatThread: chatThread)
            VStack (spacing: 0) {
                Spacer()
                if waiting {
                    WaitingIndicator()
                        .padding(.bottom, 5)
                }
                AskView(chatThread: chatThread, waiting: $waiting)
            }
        }
    }
    
    @ViewBuilder
    private func SwipeTitle() -> some View {
        Menu {
            ForEach(chatThreads) { thread in
                if chatThread != thread {
                    Button(action: { withAnimation { chatThread = thread } }) {
                        Text(thread.name ?? "New Thread \(titleEmoji.randomElement()!)")
                    }
                }
            }
        } label: {
            Text(chatThread.name ?? "New Thread \(titleEmoji.randomElement()!)")
                .frame(maxWidth: 250)
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    private func StatusBarBlur() -> some View {
        Color.clear
            .background(.ultraThinMaterial)
            .brightness(colorScheme == .dark ? -0.1 : 0.02)
            .edgesIgnoringSafeArea(.top)
            .frame(height: 0)
    }
}
