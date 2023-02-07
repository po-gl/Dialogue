//
//  ContentView.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var apiRequestHandler = ChatRequestHandler()
    @State private var inputText: String = ""
    @State private var waiting: Bool = false
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\Chat.timestamp, order: .forward)])
    private var allChats: FetchedResults<Chat>
    
    
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
                    AskView()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
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
    private func ChatLog() -> some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    VStack (spacing: 0) {
                        ForEach(allChats, id: \.id) { chat in
                            ChatView(chat: chat, geometry: geometry)
                                .padding(.top, 10)
                                .padding(.bottom, chat.id == allChats.last!.id ? 130 : 10)
                                .id(chat.id)
                        }
                        .onChange(of: allChats.count) { _ in
                            withAnimation {
                                scroll.scrollTo(allChats.last?.id, anchor: .bottom)
                            }
                        }
                        .onAppear() {
                            scroll.scrollTo(allChats.last?.id)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func AskView() -> some View {
        VStack (spacing: 0) {
            HStack {
                TextField("Ask ChatGPT...", text: $inputText, axis: .vertical)
                    .tint(Color("ServerAccent"))
                    .padding(11)
                
                Button(action: {
                    guard inputText != "" else { return }
                    withAnimation {
                        waiting = true
                    }
                    let tempText = inputText
                    Task {
                        await self.apiRequestHandler.makeRequest(text: tempText)
                        handleResponse()
                        withAnimation {
                            waiting = false
                        }
                    }
                    addUserChat()
                    inputText = ""
                }, label: {
                    Image(systemName: "paperplane")
                        .resizable()
                        .frame(width: 20, height: 20)
                })
                .buttonStyle(PopStyle(color: Color("ServerAccent"), radius: 50))
                .frame(width: 35, height: 35)
                .padding(.trailing, 5)
            }
            .background(RoundedRectangle(cornerRadius: 26).fill(.ultraThinMaterial))
            .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(colorScheme == .dark ? Color("Gray") : .black, style: StrokeStyle(lineWidth: 2)).opacity(0.5))
            .padding(.top, 5)
            .padding(.horizontal, 10)
            
            BottomSpacer()
        }
        .background(.ultraThinMaterial)
    }
    
    @ViewBuilder
    private func BottomSpacer() -> some View {
        Rectangle()
            .opacity(0)
            .frame(height: 50)
    }
    
    @ViewBuilder
    private func DataDeleteButton() -> some View {
        Button("Delete All") { deleteAllChats() }
            .buttonStyle(PopStyle(color: .red))
            .frame(width: 130, height: 54)
    }
    
    
    private func handleResponse() {
        if let data = apiRequestHandler.responseData {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let choices = json["choices"] as? [[String: Any]] {
                    if let text = choices[0]["text"] as? String {
                        print("Response: \(text)")
                        addServerChat(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else {
                    let text = String(data: apiRequestHandler.responseData!, encoding: .utf8) ?? ""
                    print("Response data: \(text)")
                    addServerChat(text.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        } else if apiRequestHandler.responseError != nil {
            print("Response error: \(apiRequestHandler.responseError!.localizedDescription)")
        }
    }
    
    
    private func addUserChat() {
        withAnimation {
            let newChat = Chat(context: viewContext)
            newChat.timestamp = Date()
            newChat.text = "\(inputText)"
            newChat.fromUser = true

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("CoreData error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addServerChat(_ text: String) {
        withAnimation {
            let newChat = Chat(context: viewContext)
            newChat.timestamp = Date()
            newChat.text = "\(text)"
            newChat.fromUser = false

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("CoreData error \(nsError), \(nsError.userInfo)")
            }
        }
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

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
//    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
