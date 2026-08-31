//
//  UpcomingAstroEventService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.08.2026.
//

import Foundation

// MARK: - Content JSON Models

struct UpcomingAstroEventContentFile: Decodable {
    let events: [UpcomingAstroEventContent]
}

struct UpcomingAstroEventContent: Decodable {
    let id: String
    let eventType: String
    let planet: String?
    let moonPhase: String?
    let eclipseType: String?
    let showBeforeDays: Int
    let priority: Int
    let suppressesEventTypes: [String]?
    let display: UpcomingAstroEventDisplay

    enum CodingKeys: String, CodingKey {
        case id
        case eventType = "event_type"
        case planet
        case moonPhase = "moon_phase"
        case eclipseType = "eclipse_type"
        case showBeforeDays = "show_before_days"
        case priority
        case suppressesEventTypes = "suppresses_event_types"
        case display
    }
}

struct UpcomingAstroEventDisplay: Decodable {
    let title: String
    let upcomingLabel: String
    let themes: [String]
    let preview: String
    let detail: String
    let actionTitle: String
    let actions: [String]
    let keepInMind: String
    let reflectionQuestion: String
    let cta: String

    enum CodingKeys: String, CodingKey {
        case title
        case upcomingLabel = "upcoming_label"
        case themes
        case preview
        case detail
        case actionTitle = "action_title"
        case actions
        case keepInMind = "keep_in_mind"
        case reflectionQuestion = "reflection_question"
        case cta
    }
}

// MARK: - UI Model

struct UpcomingAstroEvent {
    let id: String
    let key: String
    let date: Date
    let daysRemaining: Int
    let content: UpcomingAstroEventContent
}

// MARK: - Astro JSON Models

private struct UpcomingAstroDay: Decodable {
    let date: String
    let timezone: String?
    let astroSignals: [UpcomingAstroSignal]

    enum CodingKeys: String, CodingKey {
        case date
        case timezone
        case astroSignals = "astro_signals"
    }
}

private struct UpcomingAstroSignal: Decodable {
    let type: String
    let value: String?
    let planet: String?
    let status: String?
    let event: String?
    let startAt: String?
    let endAt: String?

    enum CodingKeys: String, CodingKey {
        case type
        case value
        case planet
        case status
        case event
        case startAt = "start_at"
        case endAt = "end_at"
    }
}

// MARK: - Raw Detection Model

private struct RawUpcomingAstroEvent {
    let key: String
    let date: Date
}

// MARK: - Service

final class UpcomingAstroEventService {

    static let shared = UpcomingAstroEventService()

    private let timezone =
        TimeZone(identifier: "Europe/Istanbul")
        ?? .current

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        return calendar
    }
    
    private var contentCache: UpcomingAstroEventContentFile?

    private var astroDayCache: [String: UpcomingAstroDay] = [:]
    
    private var missingAstroDayIDs = Set<String>()

    private init() {}

    // MARK: Public

    func upcomingEvents(
        referenceDate: Date = Date(),
        limit: Int = 3
    ) async -> [UpcomingAstroEvent] {

        guard
            let contentFile =
                await loadContentFileFromFirebase()
        else {
            print(
                "🔴 Firebase Upcoming Astro content bulunamadı"
            )
            return []
        }

        let astroDays =
            await loadAstroDaysFromFirebase(
                referenceDate: referenceDate,
                contentFile: contentFile
            )

        guard !astroDays.isEmpty else {
            print(
                "🔴 Firebase Upcoming Astro: astro day bulunamadı"
            )
            return []
        }

        let contentByID =
            Dictionary(
                uniqueKeysWithValues:
                    contentFile.events.map {
                        ($0.id, $0)
                    }
            )

        let rawEvents =
            detectEvents(
                in: astroDays,
                availableContent: contentByID
            )

        let today =
            calendar.startOfDay(
                for: referenceDate
            )

        var result: [UpcomingAstroEvent] = []

        for raw in rawEvents {

            guard
                let content =
                    contentByID[raw.key]
            else {
                continue
            }

            let eventDay =
                calendar.startOfDay(
                    for: raw.date
                )

            guard
                let daysRemaining =
                    calendar.dateComponents(
                        [.day],
                        from: today,
                        to: eventDay
                    ).day
            else {
                continue
            }

            guard daysRemaining >= 0 else {
                continue
            }

            guard
                daysRemaining <=
                    content.showBeforeDays
            else {
                continue
            }

            result.append(
                UpcomingAstroEvent(
                    id:
                        "\(raw.key)_\(raw.date.timeIntervalSince1970)",
                    key: raw.key,
                    date: raw.date,
                    daysRemaining: daysRemaining,
                    content: content
                )
            )
        }

        result.sort {

            if $0.date != $1.date {
                return $0.date < $1.date
            }

            return
                $0.content.priority >
                $1.content.priority
        }

        let finalResult =
            Array(
                result.prefix(limit)
            )

        print(
            "🔮 Yaklaşan olaylar:",
            finalResult.map {
                "\($0.content.display.title) | \($0.daysRemaining) gün"
            }
        )

        return finalResult
    }
    
    // MARK: - Firebase Upcoming Data

    private func loadContentFileFromFirebase()
    async -> UpcomingAstroEventContentFile? {

        if let contentCache {
            return contentCache
        }

        do {

            let content: UpcomingAstroEventContentFile =
                try await SkyDataRepository.shared
                    .fetchUpcomingAstroEventContent(
                        as: UpcomingAstroEventContentFile.self
                    )

            contentCache = content

            print("🟢 Firebase Upcoming Astro content yüklendi")

            return content

        } catch {

            print(
                "🔴 Firebase Upcoming Astro content yüklenemedi:",
                error
            )

            return nil
        }
    }

    private func loadAstroDaysFromFirebase(
        referenceDate: Date,
        contentFile: UpcomingAstroEventContentFile
    ) async -> [UpcomingAstroDay] {

        let referenceDay =
            calendar.startOfDay(
                for: referenceDate
            )

        let startDate =
            calendar.date(
                byAdding: .day,
                value: -1,
                to: referenceDay
            )
            ?? referenceDay

        let maxShowBeforeDays =
            contentFile.events
                .map(\.showBeforeDays)
                .max()
            ?? 14

        guard
            let endDate =
                calendar.date(
                    byAdding: .day,
                    value: maxShowBeforeDays,
                    to: referenceDay
                )
        else {
            return []
        }

        let repository =
            SkyDataRepository.shared

        let startID =
            repository.dateID(
                from: startDate
            )

        let endID =
            repository.dateID(
                from: endDate
            )

        var desiredIDs: [String] = []
        var currentDate = startDate

        while currentDate <= endDate {

            desiredIDs.append(
                repository.dateID(
                    from: currentDate
                )
            )

            guard
                let nextDate =
                    calendar.date(
                        byAdding: .day,
                        value: 1,
                        to: currentDate
                    )
            else {
                break
            }

            currentDate = nextDate
        }

        let hasCachedDay =
            desiredIDs.contains {
                astroDayCache[$0] != nil
            }

        if !hasCachedDay {

            do {

                let days: [UpcomingAstroDay] =
                    try await repository
                        .fetchDailyAstroRange(
                            from: startID,
                            to: endID,
                            as: UpcomingAstroDay.self
                        )

                let returnedIDs =
                    Set(
                        days.map(\.date)
                    )

                for day in days {
                    astroDayCache[day.date] = day
                }

                for id in desiredIDs
                where !returnedIDs.contains(id) {

                    missingAstroDayIDs.insert(id)
                }

                print(
                    "🟢 Firebase Upcoming Astro dailyAstroData:",
                    days.count
                )

            } catch {

                print(
                    "🔴 Firebase Upcoming Astro dailyAstroData yüklenemedi:",
                    error
                )

                return []
            }

        } else {

            let missingIDs =
                desiredIDs.filter {

                    astroDayCache[$0] == nil
                    &&
                    !missingAstroDayIDs.contains($0)
                }

            for id in missingIDs {

                do {

                    let day: UpcomingAstroDay =
                        try await repository
                            .fetchDailyAstro(
                                date: id,
                                as: UpcomingAstroDay.self
                            )

                    astroDayCache[id] = day

                    print(
                        "🟢 Firebase Upcoming Astro ek gün:",
                        id
                    )

                } catch {

                    missingAstroDayIDs.insert(id)

                    print(
                        "🟡 Firebase Upcoming Astro gün yok:",
                        id
                    )
                }
            }
        }

        return desiredIDs
            .compactMap {
                astroDayCache[$0]
            }
            .sorted {
                $0.date < $1.date
            }
    }

    // MARK: - Detect Events

    private func detectEvents(
        in days: [UpcomingAstroDay],
        availableContent:
            [String: UpcomingAstroEventContent]
    ) -> [RawUpcomingAstroEvent] {

        var rawEvents:
            [RawUpcomingAstroEvent] = []

        // 1. Yeniay ve Dolunay
        rawEvents.append(
            contentsOf:
                detectLunations(
                    in: days
                )
        )

        // 2. Tutulmalar
        rawEvents.append(
            contentsOf:
                detectEclipses(
                    in: days,
                    lunations: rawEvents
                )
        )

        // 3. Merkür / Venüs / Mars retro başlangıçları
        rawEvents.append(
            contentsOf:
                detectRetrogradeStarts(
                    in: days,
                    availableContent:
                        availableContent
                )
        )

        // Tutulma aynı günün yeniay/dolunayını bastırır.
        rawEvents =
            suppressLunationsForEclipses(
                rawEvents
            )

        // Duplicate temizliği
        var seen = Set<String>()

        let unique =
            rawEvents.filter { event in

                let day =
                    calendar.startOfDay(
                        for: event.date
                    )

                let identity =
                    "\(event.key)|\(day.timeIntervalSince1970)"

                if seen.contains(identity) {
                    return false
                }

                seen.insert(identity)
                return true
            }

        return unique
    }

    // MARK: - Lunations

    private func detectLunations(
        in days: [UpcomingAstroDay]
    ) -> [RawUpcomingAstroEvent] {

        struct PhaseOccurrence {
            let value: String
            let date: Date
            let order: Int
        }

        var occurrences:
            [PhaseOccurrence] = []

        var order = 0

        for day in days {

            guard let dayDate =
                parseDayDate(day.date)
            else {
                continue
            }

            for signal
            in day.astroSignals
            where signal.type == "moon_phase" {

                guard let value =
                    signal.value
                else {
                    continue
                }

                let effectiveDate =
                    signal.startAt
                        .flatMap(parseISO)
                    ?? dayDate

                occurrences.append(
                    PhaseOccurrence(
                        value: value,
                        date: effectiveDate,
                        order: order
                    )
                )

                order += 1
            }
        }

        occurrences.sort {

            if $0.date != $1.date {
                return $0.date < $1.date
            }

            return $0.order < $1.order
        }

        var previousPhase: String?
        var events:
            [RawUpcomingAstroEvent] = []

        for occurrence in occurrences {

            guard
                occurrence.value !=
                    previousPhase
            else {
                continue
            }

            if occurrence.value == "new_moon" {

                events.append(
                    RawUpcomingAstroEvent(
                        key: "new_moon",
                        date: occurrence.date
                    )
                )

            } else if
                occurrence.value ==
                    "full_moon" {

                events.append(
                    RawUpcomingAstroEvent(
                        key: "full_moon",
                        date: occurrence.date
                    )
                )
            }

            previousPhase =
                occurrence.value
        }

        return events
    }

    // MARK: - Eclipses

    private func detectEclipses(
        in days: [UpcomingAstroDay],
        lunations:
            [RawUpcomingAstroEvent]
    ) -> [RawUpcomingAstroEvent] {

        var result:
            [RawUpcomingAstroEvent] = []

        for day in days {

            guard let dayDate =
                parseDayDate(day.date)
            else {
                continue
            }

            for signal
            in day.astroSignals
            where signal.type == "eclipse" {

                guard let event =
                    signal.event,
                    event == "solar_eclipse"
                    || event ==
                        "lunar_eclipse"
                else {
                    continue
                }

                let matchingPhase =
                    event ==
                        "solar_eclipse"
                    ? "new_moon"
                    : "full_moon"

                let matchingLunation =
                    lunations.first {

                        $0.key ==
                            matchingPhase
                        &&
                        calendar.isDate(
                            $0.date,
                            inSameDayAs:
                                dayDate
                        )
                    }

                let eventDate =
                    matchingLunation?.date
                    ?? signal.startAt
                        .flatMap(parseISO)
                    ?? dayDate

                result.append(
                    RawUpcomingAstroEvent(
                        key: event,
                        date: eventDate
                    )
                )
            }
        }

        return result
    }

    // MARK: - Retrograde Starts

    private func detectRetrogradeStarts(
        in days: [UpcomingAstroDay],
        availableContent:
            [String: UpcomingAstroEventContent]
    ) -> [RawUpcomingAstroEvent] {

        var result:
            [RawUpcomingAstroEvent] = []

        for day in days {

            for signal
            in day.astroSignals
            where signal.type ==
                "planet_status" {

                guard
                    let planet =
                        signal.planet,
                    let status =
                        signal.status,
                    status ==
                        "retrograde",
                    let startAt =
                        signal.startAt,
                    let startDate =
                        parseISO(startAt)
                else {
                    continue
                }

                let key =
                    "\(planet)_retrograde"

                // Content JSON'da tanımlamadığımız
                // retro olayları UI'a alma.
                guard
                    availableContent[key]
                        != nil
                else {
                    continue
                }

                result.append(
                    RawUpcomingAstroEvent(
                        key: key,
                        date: startDate
                    )
                )
            }
        }

        return result
    }

    // MARK: - Eclipse Suppression

    private func suppressLunationsForEclipses(
        _ events:
            [RawUpcomingAstroEvent]
    ) -> [RawUpcomingAstroEvent] {

        let solarDates =
            events
                .filter {
                    $0.key ==
                        "solar_eclipse"
                }
                .map(\.date)

        let lunarDates =
            events
                .filter {
                    $0.key ==
                        "lunar_eclipse"
                }
                .map(\.date)

        return events.filter { event in

            if event.key == "new_moon" {

                let hasSolarEclipse =
                    solarDates.contains {
                        calendar.isDate(
                            $0,
                            inSameDayAs:
                                event.date
                        )
                    }

                return !hasSolarEclipse
            }

            if event.key == "full_moon" {

                let hasLunarEclipse =
                    lunarDates.contains {
                        calendar.isDate(
                            $0,
                            inSameDayAs:
                                event.date
                        )
                    }

                return !hasLunarEclipse
            }

            return true
        }
    }

    // MARK: - Date Parsing

    private func parseISO(
        _ string: String
    ) -> Date? {

        let formatter =
            ISO8601DateFormatter()

        return
            formatter.date(
                from: string
            )
    }

    private func parseDayDate(
        _ string: String
    ) -> Date? {

        let formatter =
            DateFormatter()

        formatter.calendar =
            calendar

        formatter.timeZone =
            timezone

        formatter.locale =
            Locale(
                identifier: "en_US_POSIX"
            )

        formatter.dateFormat =
            "yyyy-MM-dd"

        return
            formatter.date(
                from: string
            )
    }
}
