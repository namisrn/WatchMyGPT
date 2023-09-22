//
//  Menu.swift
//  watchmygpt Watch App
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI

// Definieren ein MenuItem-Modell
struct MenuItem: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var iconName: String
    var destinationView: AnyView
}

// Erstellen ein Array mit den Menüeinträgen und den zugehörigen Views
let menuItems: [MenuItem] = [
    MenuItem(title: "New Chat", subtitle: "Start new Conversation", iconName: "plus.bubble", destinationView: AnyView(NewChat())),
    MenuItem(title: "Archive", subtitle: "coming soon", iconName: "archivebox", destinationView: AnyView(Archive())),
    MenuItem(title: "Settings", subtitle: "coming soon", iconName: "gear", destinationView: AnyView(Setting()))
]



struct Menu: View {
    var body: some View {
        
        NavigationStack {
            List(menuItems) { item in
                NavigationLink(destination: item.destinationView) {
                    
                    VStack(alignment:.leading){
                        Image(systemName: item.iconName)
                            .font(.system(size: 30))
                            .foregroundColor(Color.blue)
                        
                        Spacer()
                        
                        Text(item.title)
                            .font(.title3)
                        
                        Text(item.subtitle)
                            .font(.footnote)
                            .foregroundColor(.gray)

                        }
                    }
                    .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
                    
                    
                }
                .navigationTitle("WatchMyAI")
                .containerBackground(.blue.gradient, for: .navigation)
                
            }
            .listStyle(.carousel)
        }
        
    }

#Preview {
    Menu()
}
