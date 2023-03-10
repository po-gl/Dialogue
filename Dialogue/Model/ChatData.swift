//
//  ChatData.swift
//  Dialogue
//
//  Created by Porter Glines on 3/5/23.
//

import Foundation
import CoreData
import LinkPresentation

struct ChatData {
    
    // MARK: Add Chat functions
    
    static func addUserChat(_ text: String,
                            date: Date = Date(),
                            endThread: Bool = false,
                            context: NSManagedObjectContext) {
        addChat(text, fromUser: true, date: date, endThread: endThread, metadata: nil, context: context)
    }
    
    static func addServerChat(_ text: String,
                              date: Date = Date(),
                              endThread: Bool = false,
                              context: NSManagedObjectContext) {
        Task {
            let url = URL.getURL(for: text)
            let metadata = await LPLinkMetadata.load(for: url)
            addChat(text, fromUser: false, date: date, endThread: endThread, metadata: metadata, context: context)
        }
    }
    
    static func addChat(_ text: String, fromUser: Bool, date: Date, endThread: Bool, metadata: LPLinkMetadata?, context: NSManagedObjectContext) {
        let newChat = Chat(context: context)
        newChat.timestamp = date
        newChat.text = text
        newChat.fromUser = fromUser
        
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
