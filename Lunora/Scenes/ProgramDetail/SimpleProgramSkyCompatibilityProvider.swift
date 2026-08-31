//
//  SimpleProgramSkyCompatibilityProvider.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.08.2026.
//


import Foundation

final class SimpleProgramSkyCompatibilityProvider {

    func compatibility(
        for program: Program,
        today: Date = Date()
    ) -> ProgramSkyCompatibility? {

        guard
            let astroProfile = program.astroProfile,
            astroProfile.skyMatchEnabled == true,
            astroProfile.timingType == "event_bound",
            let availability = astroProfile.availability,
            let recommendedString = availability.recommendedStartDate,
            let startString = availability.startWindowStart,
            let endString = availability.startWindowEnd
        else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(
            identifier: availability.timezone ?? "Europe/Istanbul"
        )

        guard
            let recommendedDate = formatter.date(from: recommendedString),
            let startDate = formatter.date(from: startString),
            let endDate = formatter.date(from: endString)
        else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = formatter.timeZone

        let currentDay = calendar.startOfDay(for: today)
        let recommendedDay = calendar.startOfDay(for: recommendedDate)
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        let recommendedText = formattedTurkishDate(recommendedDate)
        let windowText = formattedDateRange(
            startDate: startDate,
            endDate: endDate
        )

        // Önerilen başlangıç günü
        if currentDay == recommendedDay {

            return ProgramSkyCompatibility(
                status: .supportive,
                title: "✨ Önerilen başlangıç · Bugün",
                description: "Bu programın önerilen başlangıç günü bugün.",
                matchedItems: []
            )
        }

        // Son uygun gün
        if currentDay == endDay {

            return ProgramSkyCompatibility(
                status: .supportive,
                title: "🌙 Bugün hâlâ başlayabilirsin",
                description: "Bu program için uygun başlangıç döneminin son günü.",
                matchedItems: []
            )
        }

        // Başlangıç aralığındaki diğer günler
        if currentDay >= startDay && currentDay <= endDay {

            return ProgramSkyCompatibility(
                status: .supportive,
                title: "✨ Başlamak için uygun bir gün",
                description: "\(windowText) arasında bu programa başlayabilirsin.",
                matchedItems: []
            )
        }

        // Önerilen dönem henüz gelmediyse
        if currentDay < startDay {

            return ProgramSkyCompatibility(
                status: .supportive,
                title: "✨ Önerilen başlangıç · \(recommendedText)",
                description: "\(windowText) arasında başlayabilirsin.",
                matchedItems: []
            )
        }

        // Başlangıç dönemi bittiyse kart görünmesin
        return nil
    }

    private func formattedTurkishDate(_ date: Date) -> String {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM"

        return formatter.string(from: date)
    }

    private func formattedDateRange(
        startDate: Date,
        endDate: Date
    ) -> String {

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!

        let startMonth = calendar.component(.month, from: startDate)
        let endMonth = calendar.component(.month, from: endDate)

        let startDay = calendar.component(.day, from: startDate)
        let endDay = calendar.component(.day, from: endDate)

        if startMonth == endMonth {

            let monthFormatter = DateFormatter()
            monthFormatter.locale = Locale(identifier: "tr_TR")
            monthFormatter.dateFormat = "MMMM"

            let month = monthFormatter.string(from: endDate)

            return "\(startDay)–\(endDay) \(month)"
        }

        return "\(formattedTurkishDate(startDate)) – \(formattedTurkishDate(endDate))"
    }
}
