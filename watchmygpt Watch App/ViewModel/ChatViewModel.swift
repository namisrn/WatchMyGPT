//
//  ChatViewModel.swift
//  watchmyai Watch App
//
//  Created by Sasan Rafat Nami on 03.10.23.
//
import Foundation
import WatchKit

class ChatViewModel: ObservableObject {
    
    @Published var chatOutput: String = "How can I help you?"
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isTyping: Bool = false
    @Published var messageContext: [[String: String]] = [
        ["role": "system", "content": "You are a helpful assistant."]
    ]
    
    func splitTextIntoSegments(text: String, maxWords: Int) -> [String] {
        let words = text.split(separator: " ")
        var segments: [String] = []
        var segment: [String] = []
        var wordCount = 0
        
        for word in words {
            segment.append(String(word))
            wordCount += 1
            
            if wordCount >= maxWords {
                segments.append(segment.joined(separator: " "))
                segment.removeAll()
                wordCount = 0
            }
        }
        
        if !segment.isEmpty {
            segments.append(segment.joined(separator: " "))
        }
        
        return segments
    }
    
    func sendSegments(segments: [String]) {
        for segment in segments {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.chatOutput += "\nGPT: \(segment)"
            }
        }
    }
    
    private func getAPIKey() -> String? {
        var apiKey: String?
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                apiKey = dict["API_KEY"] as? String
            }
        }
        return apiKey
    }
    
    private func sendAsyncRequest() async throws -> ChatResponse {
        let urlString = "https://api.openai.com/v1/chat/completions"
        let apiKey = getAPIKey() ?? ""
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 1000 // Setze Timeout auf 1000 Sekunden
        
        let json: [String: Any] = ["model": "gpt-3.5-turbo", "messages": messageContext]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decodedResponse
    }
    
    func sendMessage() async {
        
        isLoading = true
        isTyping = true
        
        let userMessage = ["role": "user", "content": userInput]
        messageContext.append(userMessage)
        
        do {
            let decodedResponse = try await sendAsyncRequest()
            let content = decodedResponse.choices[0].message.content
            let segments = splitTextIntoSegments(text: content, maxWords: 200)
            
            DispatchQueue.main.async {
                self.chatOutput += "\nYou: \(self.userInput)"
                self.sendSegments(segments: segments)
                
                let assistantMessage = ["role": "assistant", "content": content]
                self.messageContext.append(assistantMessage)
                
                // Haptisches Feedback immer abspielen
                WKInterfaceDevice.current().play(.success)
                
                self.userInput = ""
                self.isLoading = false
                self.isTyping = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Fehler beim Senden der Anfrage: \(error)"
                self.isLoading = false
                self.isTyping = false
            }
        }
    }
    
    struct ChatResponse: Codable {
        struct Choice: Codable {
            let message: Message
        }
        struct Message: Codable {
            let role: String
            let content: String
        }
        let choices: [Choice]
    }
}
