//
//  FirstExperiencePreviewViewModel.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.08.2026.
//

import Foundation

@MainActor
final class FirstExperiencePreviewViewModel {

    // MARK: - Preview Content

    struct PreviewContent {
        let title: String
        let body: String
    }

    // MARK: - State

    enum State {
        case idle
        case loading
        case loaded(PreviewContent)
        case unavailable
    }

    // MARK: - Properties

    let need: FirstExperienceNeed

    private(set) var state: State = .idle {
        didSet {
            onStateChange?(state)
        }
    }

    var onStateChange: ((State) -> Void)?

    // MARK: - Init

    init(need: FirstExperienceNeed) {
        self.need = need
    }

    // MARK: - Load

    func load() async {

        state = .loading

        switch need.previewSection {

        case .energy:
            await loadEnergy()

        case .relationships:
            await loadRelationships()

        case .beauty:
            await loadBeauty()

        case .actions:
            await loadActions()

        case .programs:
            await loadPrograms()
        }
    }

    func retry() async {
        await load()
    }

    // MARK: - Energy

    private func loadEnergy() async {

        guard
            let data = await fetchTodaySkyData(),
            let interpretation = data.interpretation
        else {
            state = .unavailable
            return
        }

        let energy =
            interpretation.generalDailyInterpretation

        state = .loaded(
            PreviewContent(
                title: energy.title,
                body: energy.text
            )
        )
    }

    // MARK: - Relationships

    private func loadRelationships() async {

        guard
            let data = await fetchTodaySkyData(),
            let interpretation = data.interpretation
        else {
            state = .unavailable
            return
        }

        let relationships =
            interpretation.relationships

        let keywords =
            relationships
                .theme
                .displayKeywords
                .joined(separator: " · ")

        var sections: [String] = []

        // Tema
        if !keywords.isEmpty {
            sections.append(keywords)
        }

        // Uzun ana ilişki yorumu
        if !relationships.general.text.isEmpty {
            sections.append(
                relationships.general.text
            )
        }

        // Bugün ilişkilerde iyi gelebilecekler
        if !relationships.goodForToday.text.isEmpty {

            let goodTitle =
                relationships.goodForToday.title.isEmpty
                ? "Bugün İyi Gelebilecekler"
                : relationships.goodForToday.title

            sections.append(
                """
                \(goodTitle)
                \(relationships.goodForToday.text)
                """
            )
        }

        // Bugün dikkat / uzak durulması gerekenler
        if !relationships.avoidToday.isEmpty {

            let avoidText =
                relationships.avoidToday
                    .map { "• \($0)" }
                    .joined(separator: "\n")

            sections.append(
                """
                Bugün Dikkat
                \(avoidText)
                """
            )
        }

        state = .loaded(
            PreviewContent(
                title: relationships.general.title,
                body: sections.joined(
                    separator: "\n\n"
                )
            )
        )
    }

    // MARK: - Beauty

    private func loadBeauty() async {

        guard let data = await fetchTodaySkyData() else {
            state = .unavailable
            return
        }

        guard let beauty = data.beauty else {
            state = .loaded(
                PreviewContent(
                    title: "Güzellik & Bakım",
                    body: "Bugün için öne çıkan özel bir bakım zamanı bulunmuyor."
                )
            )
            return
        }

        let recommendations =
            beauty.beautyRecommendations

        guard !recommendations.isEmpty else {
            state = .loaded(
                PreviewContent(
                    title: "Güzellik & Bakım",
                    body: "Bugün için öne çıkan özel bir bakım zamanı bulunmuyor."
                )
            )
            return
        }

        let previewTexts =
            recommendations
                .map { $0.displayText }
                .filter { !$0.isEmpty }

        guard !previewTexts.isEmpty else {
            state = .loaded(
                PreviewContent(
                    title: "Güzellik & Bakım",
                    body: "Bugün için öne çıkan özel bir bakım zamanı bulunmuyor."
                )
            )
            return
        }

        state = .loaded(
            PreviewContent(
                title: "Güzellik & Bakım",
                body: previewTexts.joined(
                    separator: "\n\n"
                )
            )
        )
    }

    // MARK: - Actions

    private func loadActions() async {

        guard
            let data = await fetchTodaySkyData()
        else {
            state = .unavailable
            return
        }

        await AstroRulesService.shared.loadIfNeeded()

        guard
            let rules =
                AstroRulesService.shared.loadRules()
        else {
            state = .unavailable
            return
        }

        let activities =
            await AstroActivityService.shared
                .loadActivities()

        guard !activities.isEmpty else {
            state = .unavailable
            return
        }

        let ranked =
            AstroRecommendationEngine.shared.rank(
                astro: data.astro,
                activities: activities,
                rulesFile: rules
            )

        let recommendations =
            Array(
                ranked
                    .filter { $0.eligible }
                    .prefix(5)
            )

        guard !recommendations.isEmpty else {
            state = .unavailable
            return
        }

        let body =
            recommendations
                .map {
                    """
                    • \($0.activity.title)
                    \($0.activity.shortDescription)
                    """
                }
                .joined(separator: "\n\n")

        state = .loaded(
            PreviewContent(
                title: "Bugün Bunları Yapabilirsin",
                body: body
            )
        )
    }

    // MARK: - Programs

    private func loadPrograms() async {

        let programs =
            await fetchActivePrograms()

        guard !programs.isEmpty else {
            state = .unavailable
            return
        }

        // Firestore order'ına bağlı kalmayalım.
        let sortedPrograms =
            programs.sorted {
                $0.name.localizedCaseInsensitiveCompare(
                    $1.name
                ) == .orderedAscending
            }

        guard let program = sortedPrograms.first else {
            state = .unavailable
            return
        }

        var details: [String] = []

        if !program.oneSentenceSummary.isEmpty {
            details.append(
                program.oneSentenceSummary
            )
        }

        details.append(
            "\(program.durationText) · \(program.dailyDurationText)"
        )

        state = .loaded(
            PreviewContent(
                title: program.name,
                body: details.joined(
                    separator: "\n\n"
                )
            )
        )
    }

    // MARK: - Daily Sky

    private func fetchTodaySkyData()
        async -> DailySkyV2Data? {

        let dateKey =
            Self.todayDateKey()

        return await DailySkyV2Service
            .shared
            .fetchData(
                for: dateKey
            )
    }

    // MARK: - Programs Service

    private func fetchActivePrograms()
        async -> [Program] {

        await withCheckedContinuation {
            continuation in

            ProgramService.shared.fetchPrograms {
                programs in

                let activePrograms =
                    programs.filter {
                        $0.isActive == true
                    }

                continuation.resume(
                    returning: activePrograms
                )
            }
        }
    }

    // MARK: - Date

    private static func todayDateKey() -> String {

        let formatter =
            DateFormatter()

        formatter.calendar =
            Calendar(
                identifier: .gregorian
            )

        formatter.locale =
            Locale(
                identifier: "en_US_POSIX"
            )

        formatter.timeZone =
            TimeZone(
                identifier: "Europe/Istanbul"
            )

        formatter.dateFormat =
            "yyyy-MM-dd"

        return formatter.string(
            from: Date()
        )
    }
}
