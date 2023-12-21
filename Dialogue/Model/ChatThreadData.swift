//
//  ChatThreadData.swift
//  Dialogue
//
//  Created by Porter Glines on 3/26/23.
//

import Foundation
import CoreData

struct ChatThreadData {
    
    @discardableResult
    static func addThread(_ name: String? = nil, date: Date = Date(), context: NSManagedObjectContext) -> ChatThread {
        let newThread = ChatThread(context: context)
        newThread.name = name
        newThread.timestamp = date
        newThread.lastEdited = date
        
        saveContext(context, errorMessage: "CoreData error while adding ChatThread.")
        
        return newThread
    }
    
    static func renameThread(_ name: String, for thread: ChatThread, context: NSManagedObjectContext) {
        thread.name = name
        saveContext(context, errorMessage: "CoreData error while renaming ChatThread.")
    }
    
    static func changeSummary(_ summary: String, for thread: ChatThread, context: NSManagedObjectContext) {
        thread.summary = summary
        saveContext(context, errorMessage: "CoreData error while changing ChatThread summary.")
    }
    
    static func deleteThread(_ thread: ChatThread, context: NSManagedObjectContext) {
        context.delete(thread)
        saveContext(context, errorMessage: "CoreData error while deleting ChatThread.")
    }
    
    static func wasEdited(_ thread: ChatThread, context: NSManagedObjectContext) {
        thread.lastEdited = Date()
        saveContext(context, errorMessage: "CoreData error while deleting ChatThread.")
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
