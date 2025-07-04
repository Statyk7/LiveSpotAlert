import UserNotifications
import os.log

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    private let logger = OSLog(subsystem: "net.remstation.livespotalert.NotificationService", category: "NotificationService")
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        os_log("NotificationService: Processing notification with attachments", log: logger, type: .info)
        
        // Handle image attachments
        processImageAttachments(for: bestAttemptContent) { [weak self] in
            guard let self = self else { return }
            self.contentHandler?(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        os_log("NotificationService: Service extension time will expire", log: logger, type: .warning)
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func processImageAttachments(for content: UNMutableNotificationContent, completion: @escaping () -> Void) {
        // Check if we have image attachments to process
        guard !content.attachments.isEmpty else {
            os_log("NotificationService: No attachments to process", log: logger, type: .info)
            completion()
            return
        }
        
        var processedAttachments: [UNNotificationAttachment] = []
        let attachmentGroup = DispatchGroup()
        
        for attachment in content.attachments {
            attachmentGroup.enter()
            
            processImageAttachment(attachment) { [weak self] processedAttachment in
                if let processedAttachment = processedAttachment {
                    processedAttachments.append(processedAttachment)
                    os_log("NotificationService: Successfully processed attachment", log: self?.logger ?? OSLog.default, type: .info)
                } else {
                    os_log("NotificationService: Failed to process attachment", log: self?.logger ?? OSLog.default, type: .error)
                }
                attachmentGroup.leave()
            }
        }
        
        attachmentGroup.notify(queue: .main) {
            content.attachments = processedAttachments
            completion()
        }
    }
    
    private func processImageAttachment(_ attachment: UNNotificationAttachment, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let sourceURL = attachment.url
        
        os_log("NotificationService: Processing attachment from URL: %@", log: logger, type: .info, sourceURL.absoluteString)
        
        // Check if file exists at the source location
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            os_log("NotificationService: Source file does not exist at path: %@", log: logger, type: .error, sourceURL.path)
            completion(nil)
            return
        }
        
        // Create a temporary copy for the notification system
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = UUID().uuidString + "_" + sourceURL.lastPathComponent
        let tempURL = tempDirectory.appendingPathComponent(tempFileName)
        
        do {
            // Copy the file to temporary location
            try FileManager.default.copyItem(at: sourceURL, to: tempURL)
            
            // Create new attachment with copied file
            let newAttachment = try UNNotificationAttachment(identifier: attachment.identifier, url: tempURL, options: attachment.options)
            
            os_log("NotificationService: Successfully created attachment at temp URL: %@", log: logger, type: .info, tempURL.absoluteString)
            completion(newAttachment)
            
        } catch {
            os_log("NotificationService: Error processing attachment: %@", log: logger, type: .error, error.localizedDescription)
            completion(nil)
        }
    }
}