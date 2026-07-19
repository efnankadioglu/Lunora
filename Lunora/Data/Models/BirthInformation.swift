//
//  BirthInformation.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 19.07.2026.
//

import Foundation

// MARK: - Birth Information

struct BirthInformation: Codable, Equatable {

    /// Saat içermeyen doğum tarihi.
    /// Firestore örneği: "2001-07-08"
    var birthDateISO: String?

    var birthTimeMinutes: Int?
    var isBirthTimeUnknown: Bool
    var birthPlace: BirthPlace?
    var schemaVersion: Int

    init(
        birthDateISO: String? = nil,
        birthTimeMinutes: Int? = nil,
        isBirthTimeUnknown: Bool = false,
        birthPlace: BirthPlace? = nil,
        schemaVersion: Int = 1
    ) {
        self.birthDateISO = birthDateISO
        self.birthTimeMinutes = birthTimeMinutes
        self.isBirthTimeUnknown = isBirthTimeUnknown
        self.birthPlace = birthPlace
        self.schemaVersion = schemaVersion
    }
}

// MARK: - Birth Place

struct BirthPlace: Codable, Equatable {

    /// Yerleşim veya şehir adı.
    var city: String

    /// Eyalet, il veya idari bölge.
    var administrativeArea: String?

    /// Ülkenin gösterilecek adı.
    var country: String

    /// ISO ülke kodu.
    /// Örnek: TR, GB, US
    var countryCode: String?

    /// Astrolojik hesaplamalarda kullanılacak koordinatlar.
    var latitude: Double
    var longitude: Double

    /// IANA saat dilimi kimliği.
    /// Örnek: Europe/Istanbul
    var timeZoneIdentifier: String

    /// Konum sağlayıcısının mümkünse döndürdüğü kimlik.
    var placeIdentifier: String?

    init(
        city: String,
        administrativeArea: String? = nil,
        country: String,
        countryCode: String? = nil,
        latitude: Double,
        longitude: Double,
        timeZoneIdentifier: String,
        placeIdentifier: String? = nil
    ) {
        self.city = city
        self.administrativeArea = administrativeArea
        self.country = country
        self.countryCode = countryCode
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
        self.placeIdentifier = placeIdentifier
    }

    var displayName: String {
        [
            city,
            administrativeArea,
            country
        ]
        .compactMap { value in
            guard let value else {
                return nil
            }

            let trimmed = value.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            return trimmed.isEmpty ? nil : trimmed
        }
        .joined(separator: ", ")
    }
}

// MARK: - Validation

extension BirthInformation {
    
    var hasValidBirthDate: Bool {
        guard let birthDateISO else {
            return false
        }

        let trimmed = birthDateISO.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty else {
            return false
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.date(from: trimmed) != nil
    }

    var hasValidBirthTimeState: Bool {
        if isBirthTimeUnknown {
            return birthTimeMinutes == nil
        }

        guard let birthTimeMinutes else {
            return false
        }

        return (0...1439).contains(birthTimeMinutes)
    }

    var hasValidBirthPlace: Bool {
        guard let birthPlace else {
            return false
        }

        let city = birthPlace.city
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let country = birthPlace.country
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let timeZone = birthPlace.timeZoneIdentifier
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !city.isEmpty,
              !country.isEmpty,
              !timeZone.isEmpty else {
            return false
        }

        guard (-90...90).contains(birthPlace.latitude),
              (-180...180).contains(birthPlace.longitude) else {
            return false
        }

        return TimeZone(identifier: timeZone) != nil
    }

    var isCompleteForPersonalizedAstrology: Bool {
        hasValidBirthDate
            && hasValidBirthTimeState
            && hasValidBirthPlace
    }
}

// MARK: - Birth Time Helpers

extension BirthInformation {

    static func makeBirthTimeMinutes(
        hour: Int,
        minute: Int
    ) -> Int? {
        guard (0...23).contains(hour),
              (0...59).contains(minute) else {
            return nil
        }

        return (hour * 60) + minute
    }

    var birthHour: Int? {
        guard let birthTimeMinutes,
              (0...1439).contains(birthTimeMinutes) else {
            return nil
        }

        return birthTimeMinutes / 60
    }

    var birthMinute: Int? {
        guard let birthTimeMinutes,
              (0...1439).contains(birthTimeMinutes) else {
            return nil
        }

        return birthTimeMinutes % 60
    }

    var formattedBirthTime: String? {
        guard let birthHour,
              let birthMinute else {
            return nil
        }

        return String(
            format: "%02d:%02d",
            birthHour,
            birthMinute
        )
    }
}
