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
    
    @State private var isPresentingAboutPage = false
    @State private var isPresentingModelSettings = false
    @State private var isPresentingRemoveAllConfirm = false
    
    var body: some ToolbarContent {
        ToolbarItem() {
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
            
            .confirmationDialog("Are you sure?", isPresented: $isPresentingRemoveAllConfirm) {
                Button(role: .destructive, action: deleteAllChats) {
                    Text("Delete all messages")
                }
            } message: {
                Text("You cannot undo this action.")
            }
            
            .sheet(isPresented: $isPresentingAboutPage) {
                ZStack {
                    InfoPage()
                    InfoHeader()
                }
            }
            
            .sheet(isPresented: $isPresentingModelSettings) {
                ModelSettingsView(isPresented: $isPresentingModelSettings)
            }
        }
    }
    
    
    @ViewBuilder
    private func InfoHeader() -> some View {
        VStack {
            ZStack {
                HStack {
                    Button("Close") { isPresentingAboutPage = false }
                        .foregroundColor(Color("ServerAccent"))
                        .brightness(0.07)
                        .saturation(1.05)
                        .padding()
                    Spacer()
                }
            }
            .frame(height: 65)
            .background(.thinMaterial)
            Spacer()
        }
    }
    
    private func deleteAllChats() {
        completeHaptic()
        withAnimation {
            allChats.forEach { ChatData.deleteChat($0, context: viewContext) }
        }
    }
}
