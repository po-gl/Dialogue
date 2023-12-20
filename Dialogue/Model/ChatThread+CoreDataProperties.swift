//
//  ChatThread+CoreDataProperties.swift
//  Dialogue
//
//  Created by Porter Glines on 3/26/23.
//
//

import Foundation
import CoreData


extension ChatThread {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatThread> {
        return NSFetchRequest<ChatThread>(entityName: "ChatThread")
    }

    @NSManaged public var lastEdited: Date?
    @NSManaged public var name: String?
    @NSManaged public var summary: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var chats: NSSet?

}

extension ChatThread {
    public var chatsArray: [Chat] {
        get async {
            let set = chats as? Set<Chat> ?? []
            return set.sorted {
                $0.timestamp ?? Date() < $1.timestamp ?? Date()
            }
        }
    }
}

// MARK: Generated accessors for chats
extension ChatThread {

    @objc(addChatsObject:)
    @NSManaged public func addToChats(_ value: Chat)

    @objc(removeChatsObject:)
    @NSManaged public func removeFromChats(_ value: Chat)

    @objc(addChats:)
    @NSManaged public func addToChats(_ values: NSSet)

    @objc(removeChats:)
    @NSManaged public func removeFromChats(_ values: NSSet)

}

extension ChatThread : Identifiable {

}
