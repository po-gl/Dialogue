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
        addChat(text, fromUser: true, date: date, thread: thread, endThread: endThread, context: context)
    }
    
    static func addServerChat(_ text: String,
                              date: Date = Date(),
                              thread: ChatThread,
                              endThread: Bool = false,
                              context: NSManagedObjectContext) {
        addChat(text, fromUser: false, date: date, thread: thread, endThread: endThread, context: context)
    }
    
    static func addChat(_ text: String,
                        fromUser: Bool,
                        date: Date,
                        thread: ChatThread,
                        endThread: Bool,
                        context: NSManagedObjectContext) {
        let newChat = Chat(context: context)
        newChat.timestamp = date
        newChat.text = text
        newChat.fromUser = fromUser
        
        newChat.thread = thread
        
        if endThread {
            newChat.endThread = true
            newChat.endThreadDividerColor = ChatDivider.colors.randomElement()
        }
        
        saveContext(context, errorMessage: "CoreData error while adding Chat.")
    }
    
    // MARK: Fetch related Chat functions
    
    /// Looks for a chat in the thread that could be the chat's pair i.e., a user message and server response
    /// 
    /// The algorithm is to get the index of the chat in the thread (O(n)), then,
    /// depending on if the chat is from the user or not, find the next/prev chat
    /// and check if it is from the server or not. If so, return the found chat.
    static func fetchPair(for chat: Chat) async -> Chat? {
        guard let chats = await chat.thread?.chatsArray else { return nil }
        guard let index = chats.firstIndex(of: chat) else { return nil }
        
        let pairIndex = chat.fromUser ? index + 1 : index - 1;
        guard pairIndex >= 0 && pairIndex < chats.count else { return nil }
        
        let pairChat = chats[pairIndex]
        return chat.fromUser != pairChat.fromUser ? pairChat : nil
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
        context.perform {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("\(errorMessage) \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
