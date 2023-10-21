//
//  ChatViewModel.swift
//  watchmyai Watch App
//
//  Created by Sasan Rafat Nami on 03.10.23.
//
import Foundation
import WatchKit
import UserNotifications

// ViewModel für die Chat-Logik
class ChatViewModel: ObservableObject {
    
    // Veröffentlichte Variablen für die Datenbindung
    @Published var chatOutput: String = "How can I help you?"
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isTyping: Bool = false
    @Published var connectionError: Bool = false
    @Published var messageSent: Bool = false
    @Published var lastUnansweredQuery: String? = nil
    
    // Kontext für die Nachrichten
    @Published var messageContext: [[String: String]] = [
        ["role": "system", "content": "You are a helpful assistant."],
        ["role": "user", "content": "Who won the world series in 2020?"],
        ["role": "assistant", "content": "The Los Angeles Dodgers won the World Series in 2020."],
        ["role": "user", "content": "Where was it played?"]
    ]
    
    // Funktion zum Aufteilen von Text in Segmente
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
    
    // Funktion zum Senden von Segmenten an die Benutzeroberfläche
    func sendSegments(segments: [String]) {
        for segment in segments {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.chatOutput += "\nGPT: \(segment)"
            }
        }
    }
    
    // Privatfunktion zum Abrufen des API-Schlüssels aus einer Konfigurationsdatei
    private func getAPIKey() -> String? {
        var apiKey: String?
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                apiKey = dict["API_KEY"] as? String
            }
        }
        return apiKey
    }
    
    // Privatfunktion zum Abrufen des Timeout-Werts für API-Anfragen
    private func getTimeout() -> TimeInterval {
        var timeout: TimeInterval = 60.0
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                timeout = dict["API_TIMEOUT"] as? TimeInterval ?? 60.0
            }
        }
        return timeout
    }
    
    // Asynchrone Funktion zum Senden einer API-Anfrage
    private func sendAsyncRequest() async throws -> ChatResponse {
        let urlString = "https://api.openai.com/v1/chat/completions"
        let apiKey = getAPIKey() ?? ""
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = getTimeout()
        
        let json: [String: Any] = ["model": "gpt-3.5-turbo", "messages": messageContext]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decodedResponse
    }
    
    // Hauptfunktion zum Senden von Nachrichten
    func sendMessage() async {
        isLoading = true
        isTyping = true
        connectionError = false
        
        let userMessage = ["role": "user", "content": userInput]
        messageContext.append(userMessage)
        
        DispatchQueue.main.async {
            self.chatOutput += "\nYou: \(self.userInput)"
        }
        
        do {
            let decodedResponse = try await sendAsyncRequest()
            let content = decodedResponse.choices[0].message.content
            let segments = splitTextIntoSegments(text: content, maxWords: 150)
            
            DispatchQueue.main.async {
                self.messageSent = true
                self.sendSegments(segments: segments)
                
                let assistantMessage = ["role": "assistant", "content": content]
                self.messageContext.append(assistantMessage)
                
                WKInterfaceDevice.current().play(.success)
                
                self.userInput = ""
                self.isLoading = false
                self.isTyping = false
                self.lastUnansweredQuery = nil
            }
            
        } catch {
            DispatchQueue.main.async {
                self.connectionError = true
                self.isLoading = false
                self.isTyping = false
                self.lastUnansweredQuery = self.userInput
            }
        }
    }
    
    // Funktion zum erneuten Senden der letzten unbeantworteten Anfrage
    func retryMessage() async {
        if let retryQuery = self.lastUnansweredQuery {
            self.userInput = retryQuery
            await sendMessage()
        }
    }
    
    // Strukturen für die Decodierung der API-Antwort
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
    
    // Funktion zum Planen einer Benachrichtigung für Updates
    func scheduleUpdateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Update Available"
        content.body = "A new version of the app is available. Update now!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "updateNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
