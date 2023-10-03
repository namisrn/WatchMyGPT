//
//  NewChat.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI

// Die Hauptansicht für den Chat
struct NewChat: View {
    
    // Verwendung des ViewModel für die Datenbindung
    @ObservedObject var viewModel = ChatViewModel()
    
    // Der Body der View
    var body: some View {
        NavigationStack { // Navigationscontainer
            ZStack { // Stapel für Überlagerung von Views
                VStack { // Vertikaler Stapel für Anordnung der Unter-Views
                    
                    // Ein Spacer, der Platz am oberen Rand der Ansicht lässt
                    Spacer(minLength: 45)
                    
                    // ScrollView für den Chatverlauf
                    ScrollView {
                        VStack(spacing: 5) { // Vertikaler Stapel mit einem Abstand von 5 zwischen den Elementen
                            
                            // Anfangsnachricht "How can I help you?"
                            Text("How can I help you?")
                                .padding(10) // Abstand um den Text
                                .background(Color.gray.opacity(0.2)) // Hintergrundfarbe
                                .cornerRadius(10) // Eckenradius für den Hintergrund
                            
                            // Schleife durch die Chat-Ausgabe und zeige sie an
                            ForEach(viewModel.chatOutput.split(separator: "\n"), id: \.self) { message in
                                if message.hasPrefix("GPT:") { // Wenn die Nachricht von GPT kommt
                                    Text(message)
                                        .multilineTextAlignment(.leading) // Ausrichtung des Texts
                                        .padding(10) // Abstand um den Text
                                        .background(Color.gray.opacity(0.2)) // Hintergrundfarbe
                                        .cornerRadius(10) // Eckenradius
                                } else if message.hasPrefix("You:") { // Wenn die Nachricht vom Benutzer kommt
                                    Text(message)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                        .background(Color.blue.opacity(0.5))
                                        .cornerRadius(10)
                                }
                            }
                            
                            // Ladeanzeige, wenn eine Anfrage an die API gesendet wird
                            if viewModel.isLoading {
                                ProgressView()
                            }
                            
                            // Fehlermeldung, falls vorhanden
                            if let errorMessage = viewModel.errorMessage {
                                Text("Fehler: \(errorMessage)")
                                    .foregroundColor(.red) // Rote Textfarbe für Fehlermeldungen
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Maximale Breite und Ausrichtung für den VStack
                    }
                    .padding() // Abstand um die ScrollView
                    
                    // Eingabefeld und Sende-Button
                    HStack(spacing: 6) { // Horizontaler Stapel mit einem Abstand von 6 zwischen den Elementen
                        TextField("Send a message...", text: $viewModel.userInput) // Eingabefeld für den Benutzer
                        
                        // Sende-Button
                        Button(action: {
                            viewModel.sendMessage() // Aufruf der sendMessage Funktion im ViewModel
                        }) {
                            Image(systemName: "paperplane.fill") // Symbol für den Button
                                .font(Font.system(size: 25)) // Schriftgröße für das Symbol
                        }
                        .clipShape(Circle()) // Kreisförmiger Button
                        .frame(width: 55) // Breite des Buttons
                    }
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 8)) // Abstand um den HStack
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Maximale Größe für den VStack
            }
            .edgesIgnoringSafeArea(.all) // Ignoriere den Safe Area für diese Ansicht
            .containerBackground(.blue.gradient, for: .navigation) // Hintergrundfarbe für die Navigationsleiste
            .navigationTitle("New Chat") // Titel der Navigationsleiste
        }
    }
}



#Preview {
    NewChat()
}
