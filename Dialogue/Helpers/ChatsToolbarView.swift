//
//  ChatsToolbarView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/11/23.
//

import SwiftUI

struct ChatsToolbarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var chatThread: ChatThread
    private var allChats: [Chat] { chatThread.chatsArray }
    
    @State private var isPresentingAboutPage = false
    @State private var isPresentingModelSettings = false
    @State private var isPresentingRemoveAllConfirm = false
    
    var body: some View {
        Group {
            MenuButton()
        }
        
        .confirmationDialog("Are you sure?", isPresented: $isPresentingRemoveAllConfirm) {
            Button(role: .destructive, action: deleteAllChats) {
                Text("Delete all messages")
            }
        } message: {
            Text("You cannot undo this action.")
        }
        
        .sheet(isPresented: $isPresentingAboutPage) {
            InfoPage(isPresenting: $isPresentingAboutPage)
#if os(OSX)
                .frame(minWidth: 400, idealWidth: 450, maxWidth: 600)
#endif
        }
        
        .sheet(isPresented: $isPresentingModelSettings) {
            ModelSettingsView(isPresented: $isPresentingModelSettings)
#if os(OSX)
                .frame(minWidth: 450, idealWidth: 500, maxWidth: 650)
#endif
        }
    }
    
    @ViewBuilder
    private func MenuButton() -> some View {
        Menu {
            Button(action: { isPresentingAboutPage = true }) {
                Label("About ChatGPT", systemImage: "info.circle")
            }
            
            Button(action: { isPresentingModelSettings = true}) {
                Label("Model Settings", systemImage: "slider.horizontal.3")
            }
            
            Button(role: .destructive, action: { isPresentingRemoveAllConfirm = true }) {
                Label("Remove All", systemImage: "trash")
            }
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(Color("Toolbar"))
        }
    }
    
    
    private func deleteAllChats() {
        completeHaptic()
        withAnimation {
            ChatData.deleteChats(allChats, context: viewContext)
        }
    }
}
