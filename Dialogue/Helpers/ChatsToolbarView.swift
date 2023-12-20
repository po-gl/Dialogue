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
    @State private var allChats =  [Chat]()
    
    @State private var isPresentingAboutPage = false
    @State private var isPresentingModelSettings = false
    @State private var isPresentingRemoveAllConfirm = false
    
    var body: some View {
#if os(iOS)
        MenuButton()
            .confirmationDialog("Are you sure?", isPresented: $isPresentingRemoveAllConfirm) {
                Button(role: .destructive, action: deleteAllChats) {
                    Text("Delete all messages")
                }
            } message: {
                Text("You cannot undo this action.")
            }
        
            .sheet(isPresented: $isPresentingAboutPage) {
                InfoPage(isPresenting: $isPresentingAboutPage)
            }
        
            .sheet(isPresented: $isPresentingModelSettings) {
                ModelSettingsView(isPresented: $isPresentingModelSettings)
            }
            .task {
                allChats = await chatThread.chatsArray
            }
#elseif os(OSX)
        Buttons()
            .task {
                allChats = await chatThread.chatsArray
            }
#endif
    }
    
    @ViewBuilder
    private func MenuButton() -> some View {
        Menu {
            Buttons()
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(Color("Toolbar"))
        }
    }
    
    
    @ViewBuilder
    private func Buttons() -> some View {
        Button(action: { isPresentingAboutPage = true }) {
            Label("About ChatGPT", systemImage: "info.circle")
        }
        
        Button(action: { isPresentingModelSettings = true }) {
            Label("Model Settings", systemImage: "slider.horizontal.3")
        }
#if os(OSX)
        .padding(.trailing, 30)
#endif
        
        Button(role: .destructive, action: { isPresentingRemoveAllConfirm = true }) {
            Label("Delete All Messages", systemImage: "trash")
        }
        
#if os(OSX)
        .confirmationDialog("Are you sure?", isPresented: $isPresentingRemoveAllConfirm) {
            Button(role: .destructive, action: deleteAllChats) {
                Text("Delete all messages")
            }
        } message: {
            Text("You cannot undo this action.")
        }
        
        .sheet(isPresented: $isPresentingAboutPage) {
            InfoPage(isPresenting: $isPresentingAboutPage)
                .frame(minWidth: 400, idealWidth: 450, maxWidth: 600)
        }
        
        .sheet(isPresented: $isPresentingModelSettings) {
            ModelSettingsView(isPresented: $isPresentingModelSettings)
                .frame(minWidth: 450, idealWidth: 500, maxWidth: 650)
        }
#endif
    }
    
    
    private func deleteAllChats() {
        completeHaptic()
        withAnimation {
            ChatData.deleteChats(allChats, context: viewContext)
        }
    }
}
