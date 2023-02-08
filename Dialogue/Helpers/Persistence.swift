//
//  Persistence.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let userText = "Curabitur accumsan malesuada leo rhoncus tempus."
        let serverText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam nisi nulla, aliquam in porttitor quis, dignissim vel dolor. Mauris dui dui, scelerisque ac mauris et, imperdiet efficitur odio. Quisque dictum aliquam mauris ac accumsan. Ut dignissim tortor orci, in aliquet ipsum scelerisque et."
        for i in 0..<10 {
            let newItem = Chat(context: viewContext)
            newItem.timestamp = Date().addingTimeInterval(-Double(i+1) * 60.0 * 5.0)
            newItem.text = "\(i) \(i % 2 == 0 ? userText : serverText)"
            newItem.fromUser = i % 2 == 0
            if i == 3 || i == 7 {
                newItem.endThread = true
                newItem.endThreadDividerColor = ChatDivider.colors.randomElement()
            }
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Dialogue")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
