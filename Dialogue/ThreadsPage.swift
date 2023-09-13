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
    @AppStorage("shouldOnboard") private var shouldOnboard = true
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\ChatThread.lastEdited, order: .reverse)])
    private var chatThreads: FetchedResults<ChatThread>
    
    @State private var selectedThread: ChatThread?
    
    @State private var isPresentingRenameAlert = false
    @State private var threadToRename: ChatThread?
    @State private var renameText = ""
    
    
    var body: some View {
        NavigationSplitView {
#if os(iOS)
            MainContent()
#elseif os(OSX)
            SideBar()
#endif
        } detail: {
            if let selectedThread {
                ChatPage(id: selectedThread.objectID, in: viewContext)
                    .id(selectedThread.id)
            }
#if os(OSX)
            if chatThreads.isEmpty {
                EmptyChatPage()
            }
#endif
        }
        .onAppear {
            if shouldOnboard && chatThreads.isEmpty {
                addAndSelectThread()
            }
            shouldOnboard = false
        }
    }
    
#if os(iOS)
    @ViewBuilder
    private func MainContent() -> some View {
        ZStack {
            ThreadsPageBackground()
            
            ThreadList()
                .listStyle(.insetGrouped)
                .hidingTitleBackground()
        }
        .background(Color("BackgroundLighter"))
        
        .navigationTitle("Threads")
        .introspectNavigationController { navController in
            let appearence = UINavigationBarAppearance()
            appearence.backgroundColor = .clear
            appearence.backgroundEffect = .none
            navController.navigationBar.standardAppearance = appearence
        }
        
        .toolbar {
            ToolbarItem { AddThreadButton() }
        }
        .onChange(of: selectedThread) { selectedThread in
            guard selectedThread != nil else { return }
            basicHaptic()
        }
    }
    
#elseif os(OSX)
    
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
        .onAppear {
            selectedThread = chatThreads.first
        }
    }
#endif
    
    
    @ViewBuilder
    private func ThreadList() -> some View {
        List(selection: $selectedThread) {
            Section {
                if chatThreads.isEmpty { EmptyThreadListCell() }
                
                ForEach(chatThreads) { thread in
                    ThreadCell(thread)
                        .tag(thread)
                    
                        .contextMenu {
                            RenameButton(thread)
                            DeleteButton(thread)
                        }
                    
                        .swipeActions {
#if os(iOS)
                            DeleteButton(thread)
                            RenameButton(thread)
#elseif os(OSX)
                            RenameButton(thread)
                            DeleteButton(thread)
#endif
                        }
                }
                    
            } header: {
#if os(iOS)
                Color.clear.frame(height: 5)
#elseif os(macOS)
                Text("Threads")
                    .font(.system(.footnote))
#endif
            }
#if os(iOS)
            .listRowBackground(Color.clear)
#endif
        }
#if os(iOS)
        .background(.clear)
        .scrollContentBackground(.hidden)
        .coordinateSpace(name: "titleScroll")
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
#if os(iOS)
        let spacing: Double = 10
#elseif os(OSX)
        let spacing: Double = 0
#endif
        
        VStack (alignment: .leading, spacing: spacing) {
#if os(iOS)
            Text(thread.name == nil ? "New Thread" : thread.name == "" ? " " : thread.name!)
                .font(.system(.headline))
#elseif os(OSX)
            TextField("", text: .init(get: { thread.name == nil ? "New Thread" : thread.name == "" ? " " : thread.name! },
                                      set: { str in ChatThreadData.renameThread(str, for: thread, context: viewContext) }))
            .offset(x: -8)
            .font(.system(.headline))
#endif
            
            HStack {
                Text(timeFormatter.string(from: thread.lastEdited!))
                
                Text(thread.summary ?? thread.chatsArray.last?.text ?? "")
                    .lineLimit(1)
            }
            .font(.system(.subheadline))
            .opacity(0.6)
        }
    }
    
    @ViewBuilder
    private func EmptyThreadListCell() -> some View {
        Text("Added threads will show up here.")
            .opacity(0.4)
            .listRowBackground(Color.clear)
            .onTapGesture {
                addAndSelectThread()
            }
#if os(OSX)
            .font(.footnote)
#endif
    }
    
    
    @ViewBuilder
    private func AddThreadButton() -> some View {
        Button(action: {
            addAndSelectThread()
        }) {
            Label("New Thread", systemImage: "plus.app")
                .shadow(radius: 10)
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
        Button(role: .destructive, action: {
            ChatThreadData.deleteThread(thread, context: viewContext)
            if chatThreads.isEmpty {
                selectedThread = nil
            }
        }) {
            Label("Delete", systemImage: "trash")
        }.tint(.red)
    }
    
    
    private func addAndSelectThread() {
        withAnimation { let _ = ChatThreadData.addThread(context: viewContext) }
        selectedThread = chatThreads.first
    }
}


private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.doesRelativeDateFormatting = true
    formatter.dateStyle = .short
    return formatter
}()
