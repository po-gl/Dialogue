//
//  ChatData.swift
//  Dialogue
//
//  Created by Porter Glines on 3/5/23.
//

import Foundation
import CoreData

struct ChatData {
    
    // MARK: Add Chat functions
    
    static func addUserChat(_ text: String, context: NSManagedObjectContext) {
        addChat(text, fromUser: true, context: context)
    }
    
    static func addServerChat(_ text: String, context: NSManagedObjectContext) {
        addChat(text, fromUser: false, context: context)
    }
    
    static func addChat(_ text: String, fromUser: Bool, context: NSManagedObjectContext) {
        let newChat = Chat(context: context)
        newChat.timestamp = Date()
        newChat.text = text
        newChat.fromUser = fromUser
        
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
    
    static func saveContext(_ context: NSManagedObjectContext, errorMessage: String) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("\(errorMessage) \(nsError), \(nsError.userInfo)")
        }
    }
}
