//
//  DailyAstrology.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.12.2025.
//

import Foundation

struct DailyAstrology: Codable {
    let date: String
    let moonPhase: String
    let moonPhaseDetail: String
    let moonSign: String
    let moonSignDisplay: String
    let hasMoonTransition: Bool
    let moonTransitionText: String
    let moonSignPeriods: [MoonSignPeriod]

    let celestialEvents: [String]
    let suitabilityScore: Int
    let dailyComment: String

    let sections: DailyAstrologySections
    let beautyTags: [String]
    let healthDisclaimer: String

    enum CodingKeys: String, CodingKey {
        case date
        case moonPhase = "moon_phase"
        case moonPhaseDetail = "moon_phase_detail"
        case moonSign = "moon_sign"
        case moonSignDisplay = "moon_sign_display"
        case hasMoonTransition = "has_moon_transition"
        case moonTransitionText = "moon_transition_text"
        case moonSignPeriods = "moon_sign_periods"
        case celestialEvents = "celestial_events"
        case suitabilityScore = "suitability_score"
        case dailyComment = "daily_comment"
        case sections
        case beautyTags = "beauty_tags"
        case healthDisclaimer = "health_disclaimer"
    }

    init(
        date: String,
        moonPhase: String,
        moonPhaseDetail: String? = nil,
        moonSign: String,
        moonSignDisplay: String? = nil,
        hasMoonTransition: Bool = false,
        moonTransitionText: String = "",
        moonSignPeriods: [MoonSignPeriod] = [],
        celestialEvents: [String],
        suitabilityScore: Int,
        dailyComment: String,
        sections: DailyAstrologySections = .empty,
        beautyTags: [String] = [],
        healthDisclaimer: String = ""
    ) {
        self.date = date
        self.moonPhase = moonPhase
        self.moonPhaseDetail = moonPhaseDetail ?? moonPhase
        self.moonSign = moonSign
        self.moonSignDisplay = moonSignDisplay ?? moonSign
        self.hasMoonTransition = hasMoonTransition
        self.moonTransitionText = moonTransitionText
        self.moonSignPeriods = moonSignPeriods
        self.celestialEvents = celestialEvents
        self.suitabilityScore = suitabilityScore
        self.dailyComment = dailyComment
        self.sections = sections
        self.beautyTags = beautyTags
        self.healthDisclaimer = healthDisclaimer
    }
    
    // Eski servislerde kullanılan kısa DailyAstrology oluşturma biçimi için uyumluluk init'i
    init(
        date: String,
        moonPhase: String,
        dailyComment: String,
        celestialEvents: [String],
        suitabilityScore: Int,
        moonSign: String
    ) {
        self.date = date
        self.moonPhase = moonPhase
        self.moonPhaseDetail = moonPhase
        self.moonSign = moonSign
        self.moonSignDisplay = moonSign
        self.hasMoonTransition = false
        self.moonTransitionText = ""
        self.moonSignPeriods = [
            MoonSignPeriod(
                sign: moonSign,
                start: "\(date)T00:00:00+03:00",
                end: "\(date)T23:59:59+03:00"
            )
        ]
        self.celestialEvents = celestialEvents
        self.suitabilityScore = suitabilityScore
        self.dailyComment = dailyComment
        self.sections = .empty
        self.beautyTags = []
        self.healthDisclaimer = ""
    }
    

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.date = try container.decode(String.self, forKey: .date)
        self.moonPhase = try container.decode(String.self, forKey: .moonPhase)
        self.moonPhaseDetail = try container.decodeIfPresent(String.self, forKey: .moonPhaseDetail) ?? moonPhase

        self.moonSign = try container.decodeIfPresent(String.self, forKey: .moonSign) ?? ""
        self.moonSignDisplay = try container.decodeIfPresent(String.self, forKey: .moonSignDisplay) ?? moonSign
        self.hasMoonTransition = try container.decodeIfPresent(Bool.self, forKey: .hasMoonTransition) ?? false
        self.moonTransitionText = try container.decodeIfPresent(String.self, forKey: .moonTransitionText) ?? ""
        self.moonSignPeriods = try container.decodeIfPresent([MoonSignPeriod].self, forKey: .moonSignPeriods) ?? []

        self.celestialEvents = try container.decodeIfPresent([String].self, forKey: .celestialEvents) ?? []
        self.suitabilityScore = try container.decodeIfPresent(Int.self, forKey: .suitabilityScore) ?? 0
        self.dailyComment = try container.decodeIfPresent(String.self, forKey: .dailyComment) ?? ""

        self.sections = try container.decodeIfPresent(DailyAstrologySections.self, forKey: .sections) ?? .empty
        self.beautyTags = try container.decodeIfPresent([String].self, forKey: .beautyTags) ?? []
        self.healthDisclaimer = try container.decodeIfPresent(String.self, forKey: .healthDisclaimer) ?? ""
    }

    init?(firestoreData data: [String: Any]) {
        guard
            let date = data["date"] as? String,
            let moonPhase = data["moon_phase"] as? String
        else {
            return nil
        }

        self.date = date
        self.moonPhase = moonPhase
        self.moonPhaseDetail = data["moon_phase_detail"] as? String ?? moonPhase

        self.moonSign = data["moon_sign"] as? String ?? ""
        self.moonSignDisplay = data["moon_sign_display"] as? String ?? self.moonSign
        self.hasMoonTransition = data["has_moon_transition"] as? Bool ?? false
        self.moonTransitionText = data["moon_transition_text"] as? String ?? ""

        if let periodData = data["moon_sign_periods"] as? [[String: Any]] {
            self.moonSignPeriods = periodData.compactMap { MoonSignPeriod(firestoreData: $0) }
        } else {
            self.moonSignPeriods = []
        }

        self.celestialEvents = data["celestial_events"] as? [String] ?? []
        self.suitabilityScore = data["suitability_score"] as? Int ?? 0
        self.dailyComment = data["daily_comment"] as? String ?? ""

        if let sectionsData = data["sections"] as? [String: Any] {
            self.sections = DailyAstrologySections(firestoreData: sectionsData)
        } else {
            self.sections = .empty
        }

        self.beautyTags = data["beauty_tags"] as? [String] ?? []
        self.healthDisclaimer = data["health_disclaimer"] as? String ?? ""
    }
}

struct MoonSignPeriod: Codable {
    let sign: String
    let start: String
    let end: String

    init(sign: String, start: String, end: String) {
        self.sign = sign
        self.start = start
        self.end = end
    }

    init?(firestoreData data: [String: Any]) {
        guard
            let sign = data["sign"] as? String,
            let start = data["start"] as? String,
            let end = data["end"] as? String
        else {
            return nil
        }

        self.sign = sign
        self.start = start
        self.end = end
    }
}

struct DailyAstrologySections: Codable {
    let bugununEnerjisi: String
    let bugunSanaIyiGelebilecekSeyler: [String]
    let bugunBunlariYapabilirsin: [String]
    let guzellikBakimOnerisi: String
    let iliskilerdeBugun: String
    let uzakDurmanGerekenSeyler: [String]
    let yazmaCalismasi: String

    enum CodingKeys: String, CodingKey {
        case bugununEnerjisi = "bugunun_enerjisi"
        case bugunSanaIyiGelebilecekSeyler = "bugun_sana_iyi_gelebilecek_seyler"
        case bugunBunlariYapabilirsin = "bugun_bunlari_yapabilirsin"
        case guzellikBakimOnerisi = "guzellik_bakim_onerisi"
        case iliskilerdeBugun = "iliskilerde_bugun"
        case uzakDurmanGerekenSeyler = "uzak_durman_gereken_seyler"
        case yazmaCalismasi = "yazma_calismasi"
    }

    static let empty = DailyAstrologySections(
        bugununEnerjisi: "",
        bugunSanaIyiGelebilecekSeyler: [],
        bugunBunlariYapabilirsin: [],
        guzellikBakimOnerisi: "",
        iliskilerdeBugun: "",
        uzakDurmanGerekenSeyler: [],
        yazmaCalismasi: ""
    )

    init(
        bugununEnerjisi: String,
        bugunSanaIyiGelebilecekSeyler: [String],
        bugunBunlariYapabilirsin: [String],
        guzellikBakimOnerisi: String,
        iliskilerdeBugun: String,
        uzakDurmanGerekenSeyler: [String],
        yazmaCalismasi: String
    ) {
        self.bugununEnerjisi = bugununEnerjisi
        self.bugunSanaIyiGelebilecekSeyler = bugunSanaIyiGelebilecekSeyler
        self.bugunBunlariYapabilirsin = bugunBunlariYapabilirsin
        self.guzellikBakimOnerisi = guzellikBakimOnerisi
        self.iliskilerdeBugun = iliskilerdeBugun
        self.uzakDurmanGerekenSeyler = uzakDurmanGerekenSeyler
        self.yazmaCalismasi = yazmaCalismasi
    }

    init(firestoreData data: [String: Any]) {
        self.bugununEnerjisi = data["bugunun_enerjisi"] as? String ?? ""
        self.bugunSanaIyiGelebilecekSeyler = data["bugun_sana_iyi_gelebilecek_seyler"] as? [String] ?? []
        self.bugunBunlariYapabilirsin = data["bugun_bunlari_yapabilirsin"] as? [String] ?? []
        self.guzellikBakimOnerisi = data["guzellik_bakim_onerisi"] as? String ?? ""
        self.iliskilerdeBugun = data["iliskilerde_bugun"] as? String ?? ""
        self.uzakDurmanGerekenSeyler = data["uzak_durman_gereken_seyler"] as? [String] ?? []
        self.yazmaCalismasi = data["yazma_calismasi"] as? String ?? ""
    }
}
