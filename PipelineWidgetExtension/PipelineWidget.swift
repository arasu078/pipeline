import SwiftUI
import WidgetKit

private struct PipelineEntry: TimelineEntry {
    let date: Date
}

private struct PipelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PipelineEntry {
        PipelineEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (PipelineEntry) -> Void) {
        completion(PipelineEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PipelineEntry>) -> Void) {
        let entry = PipelineEntry(date: .now)
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60))))
    }
}

private struct PipelineWidgetView: View {
    let entry: PipelineEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Pipeline")
                .font(.headline)
            Text(entry.date, style: .time)
                .font(.caption)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PipelineWidget: Widget {
    let kind = "PipelineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PipelineProvider()) { entry in
            PipelineWidgetView(entry: entry)
        }
        .configurationDisplayName("Pipeline Widget")
        .description("A starter widget for Pipeline.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct PipelineWidgetBundle: WidgetBundle {
    var body: some Widget {
        PipelineWidget()
    }
}
