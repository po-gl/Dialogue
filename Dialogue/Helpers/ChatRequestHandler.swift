//
//  ChatRequestHandler.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI
import Combine

class ChatRequestHandler: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var session = URLSession.shared
    @Published var responseData: Data?
    @AppStorage("maxTokens") var maxTokens: Double = 400
    
    
    public func makeRequest(messages: [[String: String]]) async -> Data? {
        let messages: [[String: String]] = messages
        
        let apiKey = getApiKey("apikey.env")
        let model = "gpt-3.5-turbo"
        let temperature = 0.9
        let maxTokens = Int(self.maxTokens)
        let topP = 1
        let frequencyPenalty = 0.0
        let presencePenalty = 0.6
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": maxTokens,
            "top_p": topP,
            "frequency_penalty": frequencyPenalty,
            "presence_penalty": presencePenalty,
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        
        do {
            let (responseData, _) = try await session.upload(for: request, from: jsonData!)
            return responseData
        } catch {
            print("Error loading openai url: \(error.localizedDescription)")
        }
        return nil
    }
    
    
    public static func getResponseString(_ data: Data?, printDebug: Bool = true) -> String {
        if let data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let choices = json["choices"] as? [[String: Any]] {
                    if let message = choices[0]["message"] as? [String: String] {
                        if let text = message["content"] {
                            if printDebug {
                                print("Response: \(String(reflecting: text))")
                            }
                            return text.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
            } else {
                return "There was an error processing the request, try again. Error during JSON serialization."
            }
        }
        return "There was an error processing the request, try again."
    }
    
    
    private func getApiKey(_ filepath: String) -> String {
        if let path = Bundle.main.path(forResource: filepath, ofType: "") {
            do {
                return try String(contentsOfFile: path, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }
    
    private func getMessageInDataFormat(role: String, content: String) -> [String: String] {
        return ["role": role, "content": content]
    }
}


extension ChatRequestHandler {
    
    public func chat(chats: [[String: String]]) async {
        let preprompt = "You are an assistant that is helpful, creative, clever, and very friendly. When asked for images, you can provide a wiki link. Knowledge cutoff: Sep 2021. Current Date: \(dateFormatter.string(from: Date()))."
        let prepromptData = getMessageInDataFormat(role: "system", content: preprompt)
        let messages = [prepromptData] + chats
        print("Input prompt: \(String(reflecting: messages))")
        
        let responseData = await makeRequest(messages: messages)
        await MainActor.run {
            self.responseData = responseData
            
            if let responseData {
                print("URLResponseData:\(String(data: responseData, encoding: .utf8) ?? "")")
            }
        }
    }
}

extension ChatRequestHandler {
    
    public func summarize(chats: [[String: String]]) async -> String {
        let preprompt = "You are an assistant that is an expert at summarizing conversations"
        let prepromptData = getMessageInDataFormat(role: "system", content: preprompt)
        let postprompt = "Give me the topic of the previous conversation in less than 8 words."
        let postpromptData = getMessageInDataFormat(role: "user", content: postprompt)
        
        print("Summarizing...")
        let responseData = await makeRequest(messages: [prepromptData] + chats + [postpromptData])
        let summary = ChatRequestHandler.getResponseString(responseData, printDebug: false)
        print("Summary: \(summary)")
        return summary
    }
}


fileprivate let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("EEE M/d/Y")
    return formatter
}()
