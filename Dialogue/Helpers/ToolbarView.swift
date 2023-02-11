//
//  ToolbarView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/11/23.
//

import SwiftUI

struct ToolbarView: ToolbarContent {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .forward)])
    private var allChats: FetchedResults<Chat>
    
    @State private var isPresentingRemoveAllConfirm = false
    
    var body: some ToolbarContent {
        ToolbarItem() {
            Menu {
                Button(action: { }) {
                    Label("About ChatGPT", systemImage: "info.circle")
                }
                
                Button(role: .destructive, action: { isPresentingRemoveAllConfirm = true }) {
                    Label("Remove All", systemImage: "trash")
                }
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(Color("UserAccent"))
            }
            .confirmationDialog("Are you sure?", isPresented: $isPresentingRemoveAllConfirm) {
                Button(role: .destructive, action: deleteAllChats) {
                    Text("Delete all messages")
                }
            } message: {
                Text("You cannot undo this action.")
            }
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
