//
//  SkyDataRepository.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.08.2026.
//

import Foundation
import FirebaseFirestore

enum SkyDataRepositoryError: LocalizedError {
    case documentNotFound(String)
    case missingField(String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .documentNotFound(let path):
            return "Firestore document bulunamadı: \(path)"

        case .missingField(let field):
            return "Firestore field bulunamadı: \(field)"

        case .invalidData(let message):
            return "Firestore data decode edilemedi: \(message)"
        }
    }
}

final class SkyDataRepository {

    // MARK: - Singleton

    static let shared = SkyDataRepository()

    private let db: Firestore

    private init() {
        self.db = Firestore.firestore()
    }

    // MARK: - Root

    private var versionRef: DocumentReference {
        db
            .collection("skyData")
            .document("v1")
    }

    private var staticDataRef: CollectionReference {
        versionRef.collection("staticData")
    }

    // MARK: - Date ID

    func dateID(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }

    // MARK: - DAILY ASTRO DATA

    func fetchDailyAstro<T: Decodable>(
        date: String,
        as type: T.Type
    ) async throws -> T {

        try await fetchDocument(
            collection: "dailyAstroData",
            documentID: date,
            as: type
        )
    }

    func fetchDailyAstro<T: Decodable>(
        for date: Date,
        as type: T.Type
    ) async throws -> T {

        try await fetchDailyAstro(
            date: dateID(from: date),
            as: type
        )
    }
    
    func fetchDailyAstroRange<T: Decodable>(
        from startDate: String,
        to endDate: String,
        as type: T.Type
    ) async throws -> [T] {

        let snapshot = try await versionRef
            .collection("dailyAstroData")
            .order(by: FieldPath.documentID())
            .start(at: [startDate])
            .end(at: [endDate])
            .getDocuments()

        return try snapshot.documents.map { document in
            try decode(
                document.data(),
                as: type
            )
        }
    }

    // MARK: - DAILY BEAUTY DATA

    func fetchDailyBeauty<T: Decodable>(
        date: String,
        as type: T.Type
    ) async throws -> T {

        try await fetchDocument(
            collection: "dailyBeautyData",
            documentID: date,
            as: type
        )
    }

    func fetchDailyBeauty<T: Decodable>(
        for date: Date,
        as type: T.Type
    ) async throws -> T {

        try await fetchDailyBeauty(
            date: dateID(from: date),
            as: type
        )
    }

    // MARK: - DAILY INTERPRETATION DATA

    func fetchDailyInterpretation<T: Decodable>(
        date: String,
        as type: T.Type
    ) async throws -> T {

        try await fetchDocument(
            collection: "dailyInterpretationData",
            documentID: date,
            as: type
        )
    }

    func fetchDailyInterpretation<T: Decodable>(
        for date: Date,
        as type: T.Type
    ) async throws -> T {

        try await fetchDailyInterpretation(
            date: dateID(from: date),
            as: type
        )
    }

    // MARK: - ACTIVITIES

    func fetchActivities<T: Decodable>(
        as type: T.Type
    ) async throws -> [T] {

        let ref = staticDataRef.document("activities")

        let snapshot = try await ref.getDocument()

        guard let data = snapshot.data() else {
            throw SkyDataRepositoryError.documentNotFound(ref.path)
        }

        guard let items = data["items"] as? [[String: Any]] else {
            throw SkyDataRepositoryError.missingField(
                "\(ref.path)/items"
            )
        }

        return try decodeArray(
            items,
            as: T.self
        )
    }

    // MARK: - ASTRO RULES

    func fetchAstroRules<T: Decodable>(
        as type: T.Type
    ) async throws -> T {

        try await fetchStaticDocument(
            documentID: "astroRules",
            as: type
        )
    }

    // MARK: - ASTRO INPUT DEFINITIONS

    func fetchAstroInputDefinitions<T: Decodable>(
        as type: T.Type
    ) async throws -> T {

        try await fetchStaticDocument(
            documentID: "astroInputDefinitions",
            as: type
        )
    }

    // MARK: - LOCALIZATION

    func fetchAstroLocalization<T: Decodable>(
        as type: T.Type
    ) async throws -> T {

        try await fetchStaticDocument(
            documentID: "astroLocalization_tr",
            as: type
        )
    }

    // MARK: - UPCOMING ASTRO EVENT CONTENT

    func fetchUpcomingAstroEventContent<T: Decodable>(
        as type: T.Type
    ) async throws -> T {

        try await fetchStaticDocument(
            documentID: "upcomingAstroEventContent",
            as: type
        )
    }

    // MARK: - Generic Daily Document Reader

    private func fetchDocument<T: Decodable>(
        collection: String,
        documentID: String,
        as type: T.Type
    ) async throws -> T {

        let ref = versionRef
            .collection(collection)
            .document(documentID)

        let snapshot = try await ref.getDocument()

        guard let data = snapshot.data() else {
            throw SkyDataRepositoryError.documentNotFound(ref.path)
        }

        return try decode(
            data,
            as: type
        )
    }

    // MARK: - Generic Static Document Reader

    private func fetchStaticDocument<T: Decodable>(
        documentID: String,
        as type: T.Type
    ) async throws -> T {

        let ref = staticDataRef
            .document(documentID)

        let snapshot = try await ref.getDocument()

        guard var data = snapshot.data() else {
            throw SkyDataRepositoryError.documentNotFound(ref.path)
        }

        // Uploader tarafından eklenen metadata.
        // Codable modellerimizin parçası değil.
        data.removeValue(forKey: "updatedAt")

        return try decode(
            data,
            as: type
        )
    }

    // MARK: - Decoder

    private func decode<T: Decodable>(
        _ dictionary: [String: Any],
        as type: T.Type
    ) throws -> T {

        guard JSONSerialization.isValidJSONObject(dictionary) else {
            throw SkyDataRepositoryError.invalidData(
                "Firestore dictionary JSON uyumlu değil."
            )
        }

        let jsonData = try JSONSerialization.data(
            withJSONObject: dictionary
        )

        do {
            return try JSONDecoder().decode(
                T.self,
                from: jsonData
            )
        } catch {
            throw SkyDataRepositoryError.invalidData(
                error.localizedDescription
            )
        }
    }

    private func decodeArray<T: Decodable>(
        _ array: [[String: Any]],
        as type: T.Type
    ) throws -> [T] {

        guard JSONSerialization.isValidJSONObject(array) else {
            throw SkyDataRepositoryError.invalidData(
                "Firestore array JSON uyumlu değil."
            )
        }

        let jsonData = try JSONSerialization.data(
            withJSONObject: array
        )

        do {
            return try JSONDecoder().decode(
                [T].self,
                from: jsonData
            )
        } catch {
            throw SkyDataRepositoryError.invalidData(
                error.localizedDescription
            )
        }
    }
}
