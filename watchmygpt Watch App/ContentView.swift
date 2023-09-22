//
//  ContentView.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 12.09.23.
//
import SwiftUI

// Modell für einen archivierten Chat
struct ArchivedChat: Identifiable {
    var id = UUID()
    var title: String
    var conversation: String
}

// Klasse zur Verwaltung archivierter Chats
class ArchiveStore: ObservableObject {
    @Published var archivedConversations: [ArchivedChat] = []
    
    // Methode zum Hinzufügen eines archivierten Chats
    func archive(title: String, conversation: String) {
        archivedConversations.append(ArchivedChat(title: title, conversation: conversation))
    }
    
    // Methode zum Löschen eines archivierten Chats
    func delete(at offsets: IndexSet) {
        archivedConversations.remove(atOffsets: offsets)
    }
}

// Hauptansicht der App
struct ContentView: View {
    var body: some View {
        Menu()
    }
}

#Preview {
    ContentView()
}
