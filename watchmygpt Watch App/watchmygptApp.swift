//
//  watchmygptApp.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI

@main
struct watchmygpt_Watch_AppApp: App {
    @StateObject var archiveStore = ArchiveStore() // Daten-Store für archivierte Chats

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(archiveStore) // Übergabe des ArchiveStores an ContentView

        }
    }
}
