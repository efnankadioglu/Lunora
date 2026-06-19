//
//  DailySkyService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.05.2026.
//

import Foundation

final class DailySkyService {

    static let shared = DailySkyService()
    private init() {}

    private var cachedInsights: [AstroInsightEvent]?

    func makeDisplayData(from dailyAstrology: DailyAstrology) -> DailySkyDisplayData {
        let insights = loadAstroInsights()

        let moonSignInsightId = moonSignInsightId(for: dailyAstrology.moonSign)

        let moonSignInsight = insights.first { event in
            event.id == moonSignInsightId && event.isActive
        }

        let extraInsights: [AstroInsightEvent] = dailyAstrology.celestialEvents.compactMap { eventName in
            if shouldSkipEventInsightLookup(for: eventName) {
                return nil
            }

            guard let id = eventInsightId(for: eventName) else {
                print("🟡 Astro event eşleşmedi:", eventName)
                return nil
            }

            return insights.first { event in
                event.id == id && event.isActive
            }
        }

        return DailySkyDisplayData(
            dailyAstrology: dailyAstrology,
            moonSignInsight: moonSignInsight,
            extraEventInsights: extraInsights
        )
    }

    private func loadAstroInsights() -> [AstroInsightEvent] {
        if let cachedInsights = cachedInsights {
            return cachedInsights
        }

        guard let url = Bundle.main.url(
            forResource: "AstroInsightDetail",
            withExtension: "json"
        ) else {
            print("🔴 AstroInsightDetail.json bulunamadı")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let root = try JSONDecoder().decode(AstroInsightRoot.self, from: data)
            cachedInsights = root.events
            print("🟢 Astro insight count:", root.events.count)
            return root.events
        } catch {
            print("🔴 AstroInsightDetail decode hatası:", error.localizedDescription)
            return []
        }
    }

    private func moonSignInsightId(for moonSign: String) -> String? {
        let key = moonSign.trimmingCharacters(in: .whitespacesAndNewlines)

        let map: [String: String] = [
            "Koç": "moon_in_aries",
            "Boğa": "moon_in_taurus",
            "İkizler": "moon_in_gemini",
            "Yengeç": "moon_in_cancer",
            "Aslan": "moon_in_leo",
            "Başak": "moon_in_virgo",
            "Terazi": "moon_in_libra",
            "Akrep": "moon_in_scorpio",
            "Yay": "moon_in_sagittarius",
            "Oğlak": "moon_in_capricorn",
            "Kova": "moon_in_aquarius",
            "Balık": "moon_in_pisces"
        ]

        return map[key]
    }
    
    private func shouldSkipEventInsightLookup(for eventName: String) -> Bool {
        let key = eventName.trimmingCharacters(in: .whitespacesAndNewlines)

        if key.isEmpty {
            return true
        }

        // Günlük datada bilgi amaçlı duran ama AstroInsightDetail içinde ayrı kartı olmayan eventler
        if key == "Merkür Retro Gölgesi" {
            return true
        }

        // Örn: "Başak Ay Etkisi", "Aslan Ay Etkisi"
        if key.hasSuffix("Ay Etkisi") {
            return true
        }

        // Örn: "Aslan → Başak Ay Geçişi"
        if key.contains("→") && key.contains("Ay Geçişi") {
            return true
        }

        // Örn: "Yay Ay / Öğrenme Teması", "Terazi Ay / Venüs Teması"
        if key.contains("Ay /") {
            return true
        }

        return false
    }

    private func eventInsightId(for eventName: String) -> String? {
        let key = eventName.trimmingCharacters(in: .whitespacesAndNewlines)

        let map: [String: String] = [
            "Merkür Retrosu": "mercury_retrograde",
            "Venüs Retrosu": "venus_retrograde",
            "Mars Retrosu": "mars_retrograde",
            "Mars Gerilemesi": "mars_retrograde",
            "Satürn Retrosu": "saturn_retrograde",
            "Satürn Gerilemesi": "saturn_retrograde",

            "Yeniay": "new_moon",
            "Yeni Ay": "new_moon",
            "Dolunay": "full_moon",

            "Ay Tutulması": "lunar_eclipse",
            "Tam Ay Tutulması": "total_lunar_eclipse",
            "Güneş Tutulması": "solar_eclipse",
            "Halkalı Güneş Tutulması": "annular_solar_eclipse",

            "Ay-Mars Olumlu Açı": "moon_mars_positive_aspect",
            "Ay – Mars Olumlu Açı": "moon_mars_positive_aspect",
            "Ay-Mars Zorlu Açı": "moon_mars_challenging_aspect",
            "Ay – Mars Zorlu Açı": "moon_mars_challenging_aspect",

            "Ay-Satürn Olumlu Açı": "moon_saturn_positive_aspect",
            "Ay – Satürn Olumlu Açı": "moon_saturn_positive_aspect"
        ]

        return map[key]
    }
}
