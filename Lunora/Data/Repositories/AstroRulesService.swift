//
//  AstroRulesService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//
import Foundation

final class AstroRulesService {

    static let shared = AstroRulesService()

    private init() {}

    private var cachedRules: AstroRulesFile?
    private var isLoading = false

    // MARK: - Firebase Load

    func loadIfNeeded() async {

        if cachedRules != nil {
            return
        }

        if isLoading {
            while isLoading {
                try? await Task.sleep(
                    nanoseconds: 50_000_000
                )
            }

            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {

            let rulesFile: AstroRulesFile =
                try await SkyDataRepository.shared
                    .fetchAstroRules(
                        as: AstroRulesFile.self
                    )

            cachedRules = rulesFile

            print("🟢 Firebase AstroRules yüklendi")
            print(
                "🟢 Aktif rule sayısı:",
                rulesFile.rules.count
            )
            print(
                "🟢 Planet profile sayısı:",
                rulesFile.planetProfiles.count
            )
            print(
                "🟢 Base score:",
                rulesFile.scoringPolicy.baseScore
            )

        } catch {

            print(
                "🔴 Firebase AstroRules yükleme hatası:",
                error
            )
        }
    }

    // MARK: - Cached Rules

    func loadRules() -> AstroRulesFile? {
        cachedRules
    }

    func clearCache() {
        cachedRules = nil
    }
}
