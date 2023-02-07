//
//  ContentView.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .forward)])
    private var allChats: FetchedResults<Chat>
    
    @State private var waiting: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ChatLog()
                    .navigationTitle("Dialogue")
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
                ToolbarItem {
                    Button(action: deleteAllChats) {
                        Text("Clear")
                    }
                    .foregroundColor(Color("Clear"))
                }
            }
        }
    }
    
    
    @ViewBuilder
    private func DataDeleteButton() -> some View {
        Button("Delete All") { deleteAllChats() }
            .buttonStyle(PopStyle(color: .red))
            .frame(width: 130, height: 54)
    }
    

    private func deleteChats(offsets: IndexSet) {
        withAnimation {
            offsets.map { allChats[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteAllChats() {
        allChats.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
