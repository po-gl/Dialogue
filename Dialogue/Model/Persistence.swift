//
//  Persistence.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dialogue")
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
    

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let userText = "Curabitur accumsan malesuada leo rhoncus tempus."
        let serverText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam nisi nulla, aliquam in porttitor quis, dignissim vel dolor. Mauris dui dui, scelerisque ac mauris et, imperdiet efficitur odio. Quisque dictum aliquam mauris ac accumsan. Ut dignissim tortor orci, in aliquet ipsum scelerisque et."
        let codeText = """
            ```swift\n
            struct HappyView: View {\n
                @State var animate = false\n
                var body: some View {\n
                    Image(systemName: "face.smiling.inverse")\n
                        .offset(x: animate ? 10 : -10)\n
                        .onAppear {\n
                            withAnimation(.easeInOut.repeatForever()) {\n
                                animate = true\n
                            }\n
                        }\n
                }\n
            }\n
            ```
            """
        let linkText = "Here is that link you were looking for: https://en.wikipedia.org/wiki/Calico_cat"
        
        let thread = ChatThreadData.addThread(context: viewContext)
        ChatThreadData.addThread("Empty Thread", date: .now - 1, context: viewContext)
        ChatThreadData.addThread("Also Empty", date: .now - 2, context: viewContext)
        
        for i in 0..<10 {
            let date = Date().addingTimeInterval(-Double(i+1) * 60.0 * 5.0)
            let endThread = i == 3 || i == 7
            
            if i % 2 == 0 {
                ChatData.addUserChat(userText, date: date, thread: thread, endThread: endThread, context: viewContext)
            } else {
                let text = i == 3 ? codeText : i == 1 ? linkText : serverText
                ChatData.addServerChat(text, date: date, thread: thread, endThread: endThread, context: viewContext)
            }
        }
        return result
    }()
}
