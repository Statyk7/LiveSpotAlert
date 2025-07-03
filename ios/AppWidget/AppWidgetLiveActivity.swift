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
    var title = sharedDefault.string(forKey: key)
    
    // If not found with activity-specific key, try fallback key
    if title == nil {
        title = sharedDefault.string(forKey: "current_title")
        print("LIVE_ACTIVITY_DEBUG: No title found for key '\(key)', using fallback 'current_title': '\(title ?? "nil")'")
    } else {
        print("LIVE_ACTIVITY_DEBUG: Found title for key '\(key)': '\(title!)'")
    }
    
    // Debug: List all keys in UserDefaults to see what's actually stored
    let allKeys = sharedDefault.dictionaryRepresentation().keys
    let titleKeys = allKeys.filter { $0.contains("title") }
    print("LIVE_ACTIVITY_DEBUG: All title-related keys in UserDefaults: \(titleKeys)")
    
    return title ?? "LiveSpotAlert"
}

private func getLiveActivityImageData(for attributes: LiveActivitiesAppAttributes) -> String? {
    let key = attributes.prefixedKey("image")
    var imageData = sharedDefault.string(forKey: key)
    
    // If not found with activity-specific key, try fallback key
    if imageData == nil {
        imageData = sharedDefault.string(forKey: "current_image")
        print("LIVE_ACTIVITY_DEBUG: No image found for key '\(key)', using fallback 'current_image': \(imageData != nil ? "Found (\(imageData!.count) chars)" : "Not found")")
    } else {
        print("LIVE_ACTIVITY_DEBUG: Found image for key '\(key)': Found (\(imageData!.count) chars)")
    }
    
    return imageData
}

private func createUIImageFromBase64(_ base64String: String) -> UIImage? {
    guard let imageData = Data(base64Encoded: base64String) else {
        print("LiveActivity: Failed to decode base64 image data")
        return nil
    }
    
    guard let uiImage = UIImage(data: imageData) else {
        print("LiveActivity: Failed to create UIImage from decoded data")
        return nil
    }
    
    print("LiveActivity: Successfully created UIImage with size: \(uiImage.size)")
    return uiImage
}

private func getOptimizedImage(for attributes: LiveActivitiesAppAttributes) -> UIImage? {
    guard let base64String = getLiveActivityImageData(for: attributes) else {
        return nil
    }
    
    return createUIImageFromBase64(base64String)
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
            if let uiImage = getOptimizedImage(for: attributes) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                // Enhanced placeholder with better visual design
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.15),
                                    Color.blue.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.25)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                    
                    Image(systemName: "photo")
                        .font(.system(size: size * 0.4, weight: .medium))
                        .foregroundColor(.blue.opacity(0.6))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.25))
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