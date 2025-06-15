//
//  AppWidgetLiveActivity.swift
//  AppWidget
//
//  Created by Remy Baudet on 6/14/25.
//

import ActivityKit
import WidgetKit
import SwiftUI



struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState // don't forget to add this line, otherwise, live activity will not display it.

    public struct ContentState: Codable, Hashable {}

    // Static properties
    var id = UUID()
}


extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}


// Create shared default with custom group
let sharedDefault = UserDefaults(suiteName: "group.livespotalert.liveactivities")!



struct AppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello!")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom 🤩")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T 🤩")
            } minimal: {
                Text("🤩")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}



/// Live activity previews

extension LiveActivitiesAppAttributes {
    fileprivate static var preview: LiveActivitiesAppAttributes {
        LiveActivitiesAppAttributes()
    }
}

extension LiveActivitiesAppAttributes.ContentState {
    fileprivate static var smiley: LiveActivitiesAppAttributes.ContentState {
        LiveActivitiesAppAttributes.ContentState()
     }
     
     fileprivate static var starEyes: LiveActivitiesAppAttributes.ContentState {
         LiveActivitiesAppAttributes.ContentState()
     }
}

// Lock screen live activity preview
#Preview("Notification", as: .content, using:
    LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.smiley
    LiveActivitiesAppAttributes.ContentState.starEyes
}

// Minimal dynamic island preview
#Preview(as: .dynamicIsland(.minimal), using:
    LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.smiley
    LiveActivitiesAppAttributes.ContentState.starEyes
}

// Compact dynamic island preview
#Preview(as: .dynamicIsland(.compact), using:
    LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.smiley
    LiveActivitiesAppAttributes.ContentState.starEyes
}

// MinimalExpanded dynamic island preview
#Preview(as: .dynamicIsland(.expanded), using: LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.smiley
    LiveActivitiesAppAttributes.ContentState.starEyes
}
