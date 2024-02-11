//
//  WMAI_Widgets.swift
//  WMAI-Widgets
//
//  Created by Sasan Rafat Nami on 23.10.23.
//
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate)
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// Emoji-Feld wurde entfernt
struct SimpleEntry: TimelineEntry {
    let date: Date
}



// Farbschema wurde hinzugefügt, um die Farbe des Symbols zu ändern
struct mywidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        switch family {
            case .accessoryCorner:
                Image(systemName: "bubble.left.and.text.bubble.right")
                    .resizable()
                    .frame(width: 25, height: 20)
            case .accessoryCircular:
                Image(systemName: "bubble.left.and.text.bubble.right")
                    .resizable()
                    .frame(width: 25, height: 20)
            case .accessoryRectangular:
                Label("WatchMyAI", systemImage: "bubble.left.and.text.bubble.right")
            case .accessoryInline:
                Label("WatchMyAI", systemImage: "bubble.left.and.text.bubble.right")
            @unknown default:
                Text("WatchMyAI")
        }
    }
}


@main
struct WMAI_Widgets: Widget {
    let kind: String = "mywidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ){ entry in
            mywidgetEntryView(entry: entry)
                .containerBackground(.blue.gradient, for: .widget)
        }
        .configurationDisplayName("WatchMyAI")
        .description("This widget will open the app")
    }
}

#Preview(as: .accessoryRectangular) {
    WMAI_Widgets()
} timeline: {
    SimpleEntry(date: Date())
}
