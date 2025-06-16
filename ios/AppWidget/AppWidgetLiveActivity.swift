//
//  AppWidgetLiveActivity.swift
//  AppWidget
//
//  Created by Remy Baudet on 6/14/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {}

    // Static properties
    var id = UUID()
}

// MARK: - Extensions

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

// MARK: - Shared UserDefaults

let sharedDefault = UserDefaults(suiteName: "group.livespotalert.liveactivities")!

// MARK: - Live Activity Widget

struct AppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock screen/banner UI
            LiveActivityLockScreenView(attributes: context.attributes)
                .activityBackgroundTint(.blue)
                .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    LiveActivityImageView(
                        attributes: context.attributes,
                        size: 40
                    )
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(getLiveActivityTitle(for: context.attributes))
                            .font(.headline)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    // Empty for now
                    EmptyView()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Empty for now
                    EmptyView()
                }
                
            } compactLeading: {
                // Compact leading - image
                LiveActivityImageView(
                    attributes: context.attributes,
                    size: 20
                )
                
            } compactTrailing: {
                // Compact trailing - truncated title
                Text(getLiveActivityTitle(for: context.attributes))
                    .font(.caption2)
                    .lineLimit(1)
                
            } minimal: {
                // Minimal - just image or icon
                LiveActivityImageView(
                    attributes: context.attributes,
                    size: 16
                )
            }
            .widgetURL(URL(string: "livespotalert://activity/\(context.attributes.id)"))
            .keylineTint(.blue)
        }
    }
}

// MARK: - Helper Functions

private func getLiveActivityTitle(for attributes: LiveActivitiesAppAttributes) -> String {
    let key = attributes.prefixedKey("title")
    return sharedDefault.string(forKey: key) ?? "LiveSpotAlert"
}

private func getLiveActivityImageData(for attributes: LiveActivitiesAppAttributes) -> String? {
    let key = attributes.prefixedKey("image")
    return sharedDefault.string(forKey: key)
}

// MARK: - Custom Views

struct LiveActivityLockScreenView: View {
    let attributes: LiveActivitiesAppAttributes
    
    var body: some View {
        HStack(spacing: 12) {
            // Image section
            LiveActivityImageView(
                attributes: attributes,
                size: 48
            )
            
            // Content section
            VStack(alignment: .leading, spacing: 4) {
                Text(getLiveActivityTitle(for: attributes))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
    }
}

struct LiveActivityImageView: View {
    let attributes: LiveActivitiesAppAttributes
    let size: CGFloat
    
    var body: some View {
        Group {
            if let imageData = getLiveActivityImageData(for: attributes),
               let data = Data(base64Encoded: imageData),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Default placeholder with location icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        Image(systemName: "location.fill")
                            .font(.system(size: size * 0.5))
                            .foregroundColor(.blue)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview Data

extension LiveActivitiesAppAttributes {
    fileprivate static var preview: LiveActivitiesAppAttributes {
        LiveActivitiesAppAttributes()
    }
}

extension LiveActivitiesAppAttributes.ContentState {
    fileprivate static var sampleActivity: LiveActivitiesAppAttributes.ContentState {
        LiveActivitiesAppAttributes.ContentState()
    }
}

// MARK: - SwiftUI Previews

#Preview("Lock Screen", as: .content, using: LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.sampleActivity
}

#Preview("Dynamic Island - Minimal", as: .dynamicIsland(.minimal), using: LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.sampleActivity
}

#Preview("Dynamic Island - Compact", as: .dynamicIsland(.compact), using: LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.sampleActivity
}

#Preview("Dynamic Island - Expanded", as: .dynamicIsland(.expanded), using: LiveActivitiesAppAttributes.preview) {
    AppWidgetLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.sampleActivity
}