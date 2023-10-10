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
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack{
            Image("wmai")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(colorScheme == .dark ? .white : .black)
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
#if os(watchOS)
let previewWidgetFamily: WidgetFamily = .accessoryInline
#else
let previewWidgetFamily: WidgetFamily = .systemSmall
#endif

#Preview(as: .accessoryCorner) {
    mywidget()
} timeline: {
    SimpleEntry(date: Date())
}
