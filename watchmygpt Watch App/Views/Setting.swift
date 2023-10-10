//
//  Setting.swift
//  watchmygpt Watch App
//
//  Created by Sasan Rafat Nami on 21.09.23.
//

import SwiftUI

// Definieren ein MenuItem-Modell
struct SettingItem: Identifiable {
    var id = UUID()
    var title: String
    var destinationView: AnyView
}

// Erstellen ein Array mit den Menüeinträgen und den zugehörigen Views
let settingItems: [SettingItem] = [
    SettingItem(title: "Info",  destinationView: AnyView(Info())),
    SettingItem(title: "What's New", destinationView: AnyView(wahtsNew())),
    SettingItem(title: "Legal Notices",  destinationView: AnyView(LegalNotices())),

]

struct Setting: View {
    
    @ObservedObject var viewModel = ChatViewModel()  // Access the ViewModel
    
    var body: some View {
        
        NavigationStack {
            List {
                
                Button("Check for Update") {
                    // Überprüfe hier, ob ein Update verfügbar ist.
                    // Wenn ja, dann plane die Benachrichtigung.
                    self.viewModel.scheduleUpdateNotification()
                }
                
                // NavigationLink für die vorhandenen Einstellungselemente
                ForEach(settingItems) { item in
                    NavigationLink(destination: item.destinationView) {
                        VStack(alignment:.leading){
                            Text(item.title)
                        }
                    }
                    .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
                }
            }
            .containerBackground(.blue.gradient, for: .navigation)
            .navigationTitle("Setting")
        }
        .listStyle(.plain)
    }
}


struct Info: View {
    var body: some View {
        NavigationStack{
            Text("Version: 1.4 (9)")
        }
        .containerBackground(.blue.gradient, for: .navigation)
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Info")
        
        
    }
}


struct LegalNotices: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Privacy Policy")
                    .font(.headline)
                Text("No personal data is collected through this app.")
                Divider()
                Text("License")
                    .font(.headline)
                Text("All content is copyrighted and subject to licensing terms.")
                Divider()
                Text("Disclaimer")
                    .font(.headline)
                Text("We are not responsible for any damages that may arise from using this app.")
            }
            .padding()
        }
        .containerBackground(.blue.gradient, for: .navigation)
        .navigationTitle("Legal Notices")
    }
}

struct wahtsNew: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 10){
                Section(header: Text("Version 1.4:")){
                    Text("- New Chat Design")
                    Text("- Add Stack Stack")
                    Text("- UI-Improvment and Bug Fixing")
                }
                Divider()
                Section(header: Text("Version 1.3:")){
                    Text("- Improvment and Bug fixing")
                }
                Divider()
                Section(header: Text("Version 1.2:")){
                    Text("- Asynchronous Requests: Chat more smoothly with faster message loading.")
                    Text("- Haptic Feedback: Get a vibration alert when GPT's reply arrives.")
                    Text("- Connection Error Handling")
                    Text("- TryAgin Button for Incomplete Responses")
                }
            }
            .padding()
        }
        .containerBackground(.blue.gradient, for: .navigation)
        .navigationTitle("What's New")
    }
}

#Preview {
    Setting()
}
