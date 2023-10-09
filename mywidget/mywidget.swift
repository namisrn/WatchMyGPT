//
//  mywidget.swift
//  mywidget
//
//  Created by Sasan Rafat Nami on 07.10.23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of one entry, the current date and time.
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, emoji: "😀")
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct mywidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack{
            // Zeige das App-Symbol und den App-Namen an
            
            Image("wmai")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.blue)
                .frame(width: 50, height: 50, alignment: .center)
                .clipShape(Circle())
            Text("WatchMyAI")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

@main
struct mywidget: Widget {
    let kind: String = "mywidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            
            mywidgetEntryView(entry: entry)
                .containerBackground(.blue.gradient, for: .widget)
        }
        .configurationDisplayName("WatchMyAI")
        .description("This widget will open the app")
    }
}

#Preview(as: .accessoryCorner) {
    mywidget()
} timeline: {
    SimpleEntry(date: Date(), emoji: "😀")
}


