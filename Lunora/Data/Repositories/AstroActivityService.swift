//
//  AstroActivityService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//


import Foundation

final class AstroActivityService {

    static let shared = AstroActivityService()

    private init() {}

    private var cachedActivities: [AstroActivity]?

    // MARK: - Load Activities From Firebase

    func loadActivities(
        forceRefresh: Bool = false
    ) async -> [AstroActivity] {

        if !forceRefresh,
           let cachedActivities {

            return cachedActivities
        }

        do {

            let activities: [AstroActivity] =
                try await SkyDataRepository.shared.fetchActivities(
                    as: AstroActivity.self
                )

            cachedActivities = activities

            print(
                "🟢 Firebase activities yüklendi:",
                activities.count
            )

            return activities

        } catch {

            print(
                "🔴 Firebase activities yükleme hatası:",
                error
            )

            return []
        }
    }

    // MARK: - Cache

    func clearCache() {
        cachedActivities = nil
    }
}
