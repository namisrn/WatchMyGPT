//
//  watchmygptApp.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI
import UserNotifications

@main
struct watchmygpt_Watch_AppApp: App {
    
    
    init() {
        // Request permission for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            // Handle error
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
