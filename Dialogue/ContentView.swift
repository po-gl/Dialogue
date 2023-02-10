//
//  ContentView.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.undoManager) private var undoManager
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .forward)])
    private var allChats: FetchedResults<Chat>
    
    @State private var waiting: Bool = false
    
    private let titleEmoji = ["🤖", "🔮", "🌞", "👁️"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ChatLog()
                    .navigationTitle("Dialogue \(titleEmoji.randomElement()!)")
#if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
                VStack (spacing: 0) {
                    Spacer()
                    WaitingIndicator()
                        .padding(.bottom, 5)
                        .opacity(waiting ? 1.0 : 0.0)
                    AskView(waiting: $waiting)
                }
            }
            .toolbar {
                ToolbarItem() {
                    Button(action: deleteAllChats) {
                        Text("Clear")
                    }
                    .foregroundColor(Color("UserAccent"))
                }
            }
            .onAppear {
                viewContext.undoManager = undoManager
            }
#if os(iOS)
            .background(Color("Background"))
#elseif os(OSX)
            .background(Color("BackgroundMacOS"))
            .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
#endif
            
        }
    }
    
    
    private func deleteAllChats() {
        completeHaptic()
        withAnimation {
            allChats.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
