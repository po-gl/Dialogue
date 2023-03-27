//
//  ChatData.swift
//  Dialogue
//
//  Created by Porter Glines on 3/5/23.
//

import SwiftUI
import CoreData
import LinkPresentation

struct ChatData {
    
    // MARK: Add Chat functions
    
    static func addUserChat(_ text: String,
                            date: Date = Date(),
                            thread: ChatThread,
                            endThread: Bool = false,
                            context: NSManagedObjectContext) {
        addChat(text, fromUser: true, date: date, thread: thread, endThread: endThread, metadata: nil, context: context)
    }
    
    static func addServerChat(_ text: String,
                              date: Date = Date(),
                              thread: ChatThread,
                              endThread: Bool = false,
                              context: NSManagedObjectContext) {
        Task {
            let url = URL.getURL(for: text)
            let metadata = await LPLinkMetadata.load(for: url)
            await MainActor.run {
                addChat(text, fromUser: false, date: date, thread: thread, endThread: endThread, metadata: metadata, context: context)
            }
        }
    }
    
    static func addChat(_ text: String,
                        fromUser: Bool,
                        date: Date,
                        thread: ChatThread,
                        endThread: Bool,
                        metadata: LPLinkMetadata?,
                        context: NSManagedObjectContext) {
        let newChat = Chat(context: context)
        newChat.timestamp = date
        newChat.text = text
        newChat.fromUser = fromUser
        
        newChat.thread = thread
        
        if let metadata {
            newChat.metadata = metadata
        }
        
        if endThread {
            newChat.endThread = true
            newChat.endThreadDividerColor = ChatDivider.colors.randomElement()
        }
        
        saveContext(context, errorMessage: "CoreData error while adding Chat.")
    }
    
    
    // MARK: Toggle End Thread function
    
    static func toggleEndThread(chat: Chat, context: NSManagedObjectContext) {
        chat.endThread.toggle()
        if chat.endThread {
            chat.endThreadDividerColor = ChatDivider.colors.randomElement()
        }
        
        saveContext(context, errorMessage: "CoreData error while toggling end thread.")
    }
    
    
    // MARK: Delete Chat function
    
    static func deleteChat(_ chat: Chat,  context: NSManagedObjectContext) {
        context.delete(chat)
        saveContext(context, errorMessage: "CoreData error while deleting Chat.")
    }
    
    static func deleteChats(_ chats: [Chat],  context: NSManagedObjectContext) {
        chats.forEach { context.delete($0) }
        saveContext(context, errorMessage: "CoreData error while deleting multiple Chats.")
    }
    
    
    // MARK: Save context
    
    static func saveContext(_ context: NSManagedObjectContext, errorMessage: String = "CoreData error.") {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("\(errorMessage) \(nsError), \(nsError.userInfo)")
        }
    }
}
