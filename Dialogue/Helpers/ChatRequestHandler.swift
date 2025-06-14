//
//  ChatRequestHandler.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI
import Combine

enum GPTModel: String {
    case gpto4mini = "o4-mini-2025-04-16"
    case gpt4_1 = "gpt-4.1-2025-04-14"
    case gpt4_1mini = "gpt-4.1-mini-2025-04-14"
    case gpt4o = "gpt-4o"
    case gpt4_turbo = "gpt-4-turbo"
    case gpt3_5 = "gpt-3.5-turbo"
}

class ChatRequestHandler: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var session = URLSession.shared
    @Published var responseData: Data?
    @AppStorage("maxTokens") var maxTokens: Double = 1300
    @AppStorage("gptModel") var gptModel: GPTModel = .gpt4_1

    private static let reasoningModels: [GPTModel] = [.gpto4mini]

    public func makeRequest(
        messages: [[String: String]],
        model: GPTModel) async -> Data? {
        let isReasoningModel = ChatRequestHandler.reasoningModels.contains(model)
        let messages: [[String: String]] = messages

        let apiKey = getApiKey("apikey.env")
        let temperature = isReasoningModel ? 1.0 : 0.9
        let maxTokens = Int(self.maxTokens)
        let topP = 1
        let frequencyPenalty = 0.0
        let presencePenalty = 0.6

        var requestBody: [String: Any] = [
            "model": model.rawValue,
            "messages": messages,
            "temperature": temperature,
            "max_completion_tokens": maxTokens,
            "top_p": topP,
            "frequency_penalty": frequencyPenalty,
        ]

        if !isReasoningModel {
            // inputs that are incompatible with the reasoning models
            requestBody["presence_penalty"] = presencePenalty
        }

        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        do {
            let (responseData, _) = try await session.data(for: request)
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
                    if let message = choices[0]["message"] as? [String: Any] {
                        if let text = message["content"] as? String {
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
        
        let responseData = await makeRequest(messages: messages, model: gptModel)
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
        let model: GPTModel = .gpt4_1mini
        let preprompt = "You are an assistant that is an expert at summarizing conversations"
        let prepromptData = getMessageInDataFormat(role: "system", content: preprompt)
        let postprompt = "Give me the topic of the previous conversation in less than 8 words."
        let postpromptData = getMessageInDataFormat(role: "user", content: postprompt)
        
        print("Summarizing...")
        let responseData = await makeRequest(messages: [prepromptData] + chats + [postpromptData], model: model)
        let summary = ChatRequestHandler.getResponseString(responseData, printDebug: false)
        print("Summary: \(summary)")
        return summary
    }
}

extension ChatRequestHandler {
    
    public func summarizeTitle(chats: [[String: String]]) async -> String {
        let model: GPTModel = .gpt4_1mini
        let preprompt = "You are an assistant that is an expert at summarizing conversations into thread titles"
        let prepromptData = getMessageInDataFormat(role: "system", content: preprompt)
        let postprompt = "Give me the topic of the previous conversation in less than 4 words."
        let postpromptData = getMessageInDataFormat(role: "user", content: postprompt)
        
        print("Summarizing Title...")
        let responseData = await makeRequest(messages: [prepromptData] + chats + [postpromptData], model: model)
        let summary = ChatRequestHandler.getResponseString(responseData, printDebug: false)
        print("Summary Title: \(summary)")
        return summary
    }
}


fileprivate let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("EEE M/d/Y")
    return formatter
}()
