//
//  NotificationInboxItem.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.08.2026.
//

import Foundation
import FirebaseFirestore

struct NotificationInboxItem {

    let id: String
    let title: String
    let body: String

    let category: String?
    let type: String?
    let route: String?

    let createdAt: Date
    let readAt: Date?

    var isRead: Bool {
        readAt != nil
    }

    init?(
        id: String,
        data: [String: Any]
    ) {
        guard
            let title = data["title"] as? String,
            let body = data["body"] as? String
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.body = body

        self.category = data["category"] as? String
        self.type = data["type"] as? String
        self.route = data["route"] as? String

        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }

        if let timestamp = data["readAt"] as? Timestamp {
            self.readAt = timestamp.dateValue()
        } else {
            self.readAt = nil
        }
    }
}
