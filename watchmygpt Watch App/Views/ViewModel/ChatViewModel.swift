//
//  ChatViewModel.swift
//  watchmyai Watch App
//
//  Created by Sasan Rafat Nami on 03.10.23.
//
import Foundation
import WatchKit
import UserNotifications

class ChatViewModel: ObservableObject {
    
    // Veröffentlichte Variablen für den Datenfluss zwischen ViewModel und View
    @Published var chatOutput: String = "How can I help you?"
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isTyping: Bool = false
    @Published var connectionError: Bool = false
    @Published var messageSent: Bool = false
    
    // Kontext für die Konversation mit dem GPT-Modell
    @Published var messageContext: [[String: String]] = [
        ["role": "system", "content": "You are a helpful assistant."]
    ]
    
    // Funktion zum Aufteilen des Textes in Segmente
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
    
    // Funktion zum Senden von segmentierten Nachrichten an die View
    func sendSegments(segments: [String]) {
        for segment in segments {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.chatOutput += "\nGPT: \(segment)"
            }
        }
    }
    
    // Funktion zum Abrufen des API-Schlüssels aus der Config.plist-Datei
    private func getAPIKey() -> String? {
        var apiKey: String?
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                apiKey = dict["API_KEY"] as? String
            }
        }
        return apiKey
    }
    
    // Funktion zum Abrufen des Timeout-Werts aus der AppConfig.plist-Datei
    private func getTimeout() -> TimeInterval {
        var timeout: TimeInterval = 60.0  // Standardwert
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                timeout = dict["API_TIMEOUT"] as? TimeInterval ?? 60.0
            }
        }
        return timeout
    }
    
    // Asynchrone Funktion zum Senden einer API-Anfrage und zum Empfangen einer Antwort
    private func sendAsyncRequest() async throws -> ChatResponse {
        let urlString = "https://api.openai.com/v1/chat/completions"
        let apiKey = getAPIKey() ?? ""
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = getTimeout()  // Verwende den konfigurierten Timeout-Wert
        
        let json: [String: Any] = ["model": "gpt-3.5-turbo", "messages": messageContext]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decodedResponse
    }
    
    // Asynchrone Funktion zum Senden einer Nachricht
    func sendMessage() async {
        
        isLoading = true
        isTyping = true
        connectionError = false  // Setze connectionError auf false
        
        // Füge die Benutzernachricht dem Kontext hinzu
        let userMessage = ["role": "user", "content": userInput]
        messageContext.append(userMessage)
        
        // Zeige die Benutzernachricht in der View an
        DispatchQueue.main.async {
            self.chatOutput += "\nYou: \(self.userInput)"
        }
        
        do {
            // Versuche, eine Antwort vom GPT-Modell zu erhalten
            let decodedResponse = try await sendAsyncRequest()
            let content = decodedResponse.choices[0].message.content
            let segments = splitTextIntoSegments(text: content, maxWords: 150)
            
            // Aktualisiere die View mit der Antwort
            DispatchQueue.main.async {
                self.messageSent = true
                self.sendSegments(segments: segments)
                
                // Füge die Antwort dem Kontext hinzu
                let assistantMessage = ["role": "assistant", "content": content]
                self.messageContext.append(assistantMessage)
                
                // Spiele haptisches Feedback ab
                WKInterfaceDevice.current().play(.success)
                
                // Setze den Zustand zurück
                self.userInput = ""
                self.isLoading = false
                self.isTyping = false
            }
            
        } catch {
            // Fehlerbehandlung
            DispatchQueue.main.async {
                self.connectionError = true
                self.isLoading = false
                self.isTyping = false
            }
        }
    }
    
    // Struktur für die Antwort des GPT-Modells
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
    
    // Asynchrone Funktion zum Fortsetzen einer Nachricht
    func continueMessage() async {
        // Das System ist im "Schreibmodus"
        isTyping = true
        
        do {
            let decodedResponse = try await sendAsyncRequest()
            
            let content = decodedResponse.choices[0].message.content
            let segments = splitTextIntoSegments(text: content, maxWords: 200)
            
            DispatchQueue.main.async {
                self.sendSegments(segments: segments)
                
                let assistantMessage = ["role": "assistant", "content": content]
                self.messageContext.append(assistantMessage)
                
                self.isTyping = false
            }
        } catch {
            DispatchQueue.main.async {
                self.connectionError = true
                self.isTyping = false
            }
        }
    }
    
    // Funktion zur Überprüfung, ob die letzte Antwort des Modells vollständig ist
    func isLastResponseComplete() -> Bool {
        if let lastResponse = chatOutput.split(separator: "\n").last(where: { $0.hasPrefix("GPT:") }) {
            let trimmed = lastResponse.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastChar = trimmed.last
            return lastChar == "." || lastChar == "?" || lastChar == "!"
        }
        return true
    }
    
    func scheduleUpdateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Update Available"
        content.body = "A new version of the app is available. Update now!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "updateNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    
}
