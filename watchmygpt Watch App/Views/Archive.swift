//
//  Archive.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 21.09.23.
//

import SwiftUI

struct Archive: View {
    
    @EnvironmentObject var archiveStore: ArchiveStore

    
    var body: some View {
        NavigationStack{
            List {
                // Durchläuft alle archivierten Gespräche und zeigt sie an
                ForEach(archiveStore.archivedConversations) { chat in
                    NavigationLink(destination: Text(chat.conversation)) {
                        Text(chat.title)
                    }
                }
                .onDelete(perform: { indexSet in
                    archiveStore.delete(at: indexSet)
                })
            }

            .containerBackground(.blue.gradient, for: .navigation)
            .navigationTitle("Archive")
        }
        

    }
}

#Preview {
    Archive()
}
