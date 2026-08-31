//
//  DailySkyV2Service.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//

import Foundation

final class DailySkyV2Service {

    static let shared = DailySkyV2Service()

    private init() {}

    // MARK: - Cache

    private var astroCache: [String: DailyAstroDataDay] = [:]

    private var interpretationCache:
        [String: DailyInterpretationDataDay] = [:]

    private var beautyCache:
        [String: DailyBeautyDataDay] = [:]

    // MARK: - Firebase Fetch

    func fetchTodayData(
        forceRefresh: Bool = false
    ) async -> DailySkyV2Data? {

        await fetchData(
            for: todayDateString(),
            forceRefresh: forceRefresh
        )
    }

    func fetchData(
        for date: String,
        forceRefresh: Bool = false
    ) async -> DailySkyV2Data? {

        // Daha önce Firebase'den geldiyse tekrar read yapma.
        if !forceRefresh,
           let cached = getData(for: date) {

            return cached
        }

        // MARK: Astro - zorunlu

        let astro: DailyAstroDataDay

        do {

            astro =
                try await SkyDataRepository.shared
                    .fetchDailyAstro(
                        date: date,
                        as: DailyAstroDataDay.self
                    )

            astroCache[date] = astro

            print(
                "🟢 Firebase dailyAstroData:",
                date
            )

        } catch {

            print(
                "🔴 Firebase dailyAstroData yüklenemedi:",
                date,
                error
            )

            return nil
        }

        // MARK: Interpretation - opsiyonel

        var interpretation:
            DailyInterpretationDataDay?

        do {

            let item: DailyInterpretationDataDay =
                try await SkyDataRepository.shared
                    .fetchDailyInterpretation(
                        date: date,
                        as: DailyInterpretationDataDay.self
                    )

            interpretationCache[date] = item
            interpretation = item

            print(
                "🟢 Firebase dailyInterpretationData:",
                date
            )

        } catch {

            interpretation =
                interpretationCache[date]

            print(
                "🟡 dailyInterpretationData yok:",
                date
            )
        }

        // MARK: Beauty - opsiyonel

        var beauty:
            DailyBeautyDataDay?

        do {

            let item: DailyBeautyDataDay =
                try await SkyDataRepository.shared
                    .fetchDailyBeauty(
                        date: date,
                        as: DailyBeautyDataDay.self
                    )

            beautyCache[date] = item
            beauty = item

            print(
                "🟢 Firebase dailyBeautyData:",
                date
            )

        } catch {

            beauty =
                beautyCache[date]

            print(
                "🟡 dailyBeautyData yok:",
                date
            )
        }

        return DailySkyV2Data(
            astro: astro,
            interpretation: interpretation,
            beauty: beauty
        )
    }

    // MARK: - Existing Sync API
    //
    // Bunları özellikle bırakıyoruz.
    // Eski kodlar compile olmaya devam edecek.
    // Artık JSON okumuyorlar; sadece Firebase cache'ine bakıyorlar.

    func getTodayData() -> DailySkyV2Data? {

        getData(
            for: todayDateString()
        )
    }

    func getData(
        for date: String
    ) -> DailySkyV2Data? {

        guard let astro =
                astroCache[date]
        else {
            return nil
        }

        return DailySkyV2Data(
            astro: astro,
            interpretation:
                interpretationCache[date],
            beauty:
                beautyCache[date]
        )
    }

    // MARK: - Cache

    func clearCache() {

        astroCache.removeAll()
        interpretationCache.removeAll()
        beautyCache.removeAll()
    }

    // MARK: - Date

    private func todayDateString() -> String {

        let formatter =
            DateFormatter()

        formatter.calendar =
            Calendar(identifier: .gregorian)

        formatter.locale =
            Locale(identifier: "en_US_POSIX")

        formatter.dateFormat =
            "yyyy-MM-dd"

        formatter.timeZone =
            TimeZone(
                identifier: "Europe/Istanbul"
            )

        return formatter.string(
            from: Date()
        )
    }
}
