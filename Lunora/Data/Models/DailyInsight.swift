//
//  DailyInsight.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 14.05.2026.
//

import Foundation
import FirebaseFirestore

struct DailyInsight {
    let dateKey: String
    let title: String
    let subtitle: String
    let body: String
    let source: String
    let createdAt: Timestamp?

    init(
        dateKey: String,
        title: String,
        subtitle: String,
        body: String,
        source: String,
        createdAt: Timestamp?
    ) {
        self.dateKey = dateKey
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.source = source
        self.createdAt = createdAt
    }

    init?(documentId: String, data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let subtitle = data["subtitle"] as? String,
            let body = data["body"] as? String
        else {
            return nil
        }

        self.dateKey = data["dateKey"] as? String ?? documentId
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.source = data["source"] as? String ?? "unknown"
        self.createdAt = data["createdAt"] as? Timestamp
    }

    static func fallback(dateKey: String) -> DailyInsight {
        return DailyInsight(
            dateKey: dateKey,
            title: "İç sesine dön",
            subtitle: "Küçük adım da yeterli.",
            body: "Bugün kendine yüklenmeden ilerlemen yeterli. Bir görevi bilinçle tamamlamak bile yolculuğunu canlı tutar.",
            source: "fallback",
            createdAt: nil
        )
    }
}
