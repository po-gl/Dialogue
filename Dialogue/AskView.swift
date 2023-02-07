//
//  AskView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/7/23.
//

import SwiftUI

struct AskView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var apiRequestHandler = ChatRequestHandler()
    
    @State private var inputText: String = ""
    
    @Binding var waiting: Bool
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                TextField("Ask ChatGPT...", text: $inputText, axis: .vertical)
                    .tint(Color("ServerAccent"))
                    .padding(11)
                
                Button(action: {
                    guard inputText != "" else { return }
                    basicHaptic()
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
            .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(colorScheme == .dark ? Color("Gray") : .black, style: StrokeStyle(lineWidth: 2)).opacity(0.5))
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
        }
        .background(.ultraThinMaterial)
    }
    
    
    private func handleResponse() {
        completeHaptic()
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
}

