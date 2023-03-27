//
//  ThreadsPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/26/23.
//

import SwiftUI
import Combine
import Introspect

struct ThreadsPage: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\ChatThread.lastEdited, order: .reverse)])
    private var chatThreads: FetchedResults<ChatThread>
    
    @State private var selectedThread: ChatThread?
    
    @State private var isPresentingAboutPage = false
    
    @State private var isPresentingRenameAlert = false
    @State private var threadToRename: ChatThread?
    @State private var renameText = ""
    
    
    var body: some View {
        NavigationSplitView {
#if os(iOS)
            MainContent()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) { InfoButton() }
                    ToolbarItem { AddThreadButton() }
                }
                .introspectNavigationController { navController in
                    navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
                    navController.navigationBar.isTranslucent = true
                }
                .navigationTitle("Threads")
#elseif os(OSX)
            SideBar()
#endif
        } detail: {
            if let selectedThread {
                ChatPage(chatThread: selectedThread)
            }
        }
    }
    
    @ViewBuilder
    private func MainContent() -> some View {
        ZStack {
            ThreadsPageBackground()
            
            ThreadList()
#if os(iOS)
                .listStyle(.insetGrouped)
#endif
        }
    }
    
    @ViewBuilder
    private func SideBar() -> some View {
        VStack (alignment: .leading) {
            ThreadList()
                .listStyle(.sidebar)
            AddThreadButton()
                .buttonStyle(.plain)
                .padding(10)
                .opacity(0.8)
        }
    }
    
    
    @ViewBuilder
    private func ThreadList() -> some View {
        List(selection: $selectedThread) {
            Section {
                ForEach(chatThreads) { thread in
                    ThreadCell(thread)
                        .tag(thread)
                    
                        .contextMenu {
                            RenameButton(thread)
                            DeleteButton(thread)
                        }
                    
                        .swipeActions(edge: .trailing) {
                            DeleteButton(thread)
                            RenameButton(thread)
                        }
                }
            } header: {
                Color.clear.frame(height: 5)
            }
#if os(iOS)
            .listRowBackground(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
#endif
        }
#if os(iOS)
        .background(.clear)
        .scrollContentBackground(.hidden)
#endif
        
        .alert("Rename Thread", isPresented: $isPresentingRenameAlert) {
            TextField("" , text: $renameText)
#if os(iOS)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
#endif
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if let threadToRename {
                    ChatThreadData.renameThread(renameText, for: threadToRename, context: viewContext)
                }
            }
        }
    }
    
    @ViewBuilder
    private func ThreadCell(_ thread: ChatThread) -> some View {
        VStack (alignment: .leading) {
            Text(thread.name == nil ? "New Thread" : thread.name == "" ? " " : thread.name!)
                .font(.system(.headline))
            
            HStack {
                Text(timeFormatter.string(from: thread.lastEdited!))
                
                Text(thread.chatsArray.last?.text ?? "")
                    .lineLimit(1)
            }
            .font(.system(.subheadline))
            .opacity(0.6)
        }
    }
    
    
    @ViewBuilder
    private func AddThreadButton() -> some View {
        Button(action: {
            withAnimation { let _ = ChatThreadData.addThread(context: viewContext) }
        }) {
            Label("Add Thread", systemImage: "plus.app")
        }
    }
    
    @ViewBuilder
    private func InfoButton() -> some View {
        Button(action: { isPresentingAboutPage = true }) {
            Label("About", systemImage: "info.circle")
        }
        .sheet(isPresented: $isPresentingAboutPage) {
            InfoPage(isPresenting: $isPresentingAboutPage)
        }
    }
    
    
    @ViewBuilder
    private func RenameButton(_ thread: ChatThread) -> some View {
        Button(action: {
            renameText = thread.name ?? "New Thread"
            threadToRename = thread
            isPresentingRenameAlert = true
        }) {
            Label("Rename", systemImage: "pencil.line")
        }.tint(Color("ServerAccent"))
    }
    
    @ViewBuilder
    private func DeleteButton(_ thread: ChatThread) -> some View {
        Button(role: .destructive, action: { ChatThreadData.deleteThread(thread, context: viewContext) }) {
            Label("Delete", systemImage: "trash")
        }.tint(.red)
    }
    
    
    @ViewBuilder
    private func ThreadsPageBackground() -> some View {
        VStack {
            Circle().fill(Color("User"))
                .blur(radius: 40)
                .offset(x: -280, y: -100)
            Spacer()
            ZStack {
                Circle().fill(Color("Server"))
                    .blur(radius: 50)
                    .offset(x: -0, y: 200)
                    .scaleEffect(0.9)
                Circle().fill(Color("ServerAccent"))
                    .blur(radius: 50)
                    .offset(x: -0, y: 300)
                    .scaleEffect(0.9)
                Circle().fill(Color("UserAccent"))
                    .blur(radius: 50)
                    .offset(x: 230, y: 100)
                
                Circle().fill(colorScheme == .dark ? Color("ServerAccent") : .black)
                    .blur(radius: 80)
                    .offset(x: 200, y: 280)
                    .opacity(0.5)
            }
        }
        .ignoresSafeArea()
        .brightness(colorScheme == .dark ? -0.05 : 0.05)
        .saturation(colorScheme == .dark ? 1.05 : 1.05)
    }
}


private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.doesRelativeDateFormatting = true
    formatter.dateStyle = .short
    return formatter
}()
