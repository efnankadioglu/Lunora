//
//  BirthInformationRepository.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 19.07.2026.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - BirthInformationRepository

final class BirthInformationRepository {

    static let shared = BirthInformationRepository()

    private let db: Firestore

    private init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    // MARK: Firestore Path

    /// users/{uid}/private_data/birth_information
    private func documentReference(
        for uid: String
    ) -> DocumentReference {
        db.collection("users")
            .document(uid)
            .collection("private_data")
            .document("birth_information")
    }

    // MARK: Fetch

    func fetch(
        uid: String,
        completion: @escaping (Result<BirthInformation?, Error>) -> Void
    ) {
        guard !uid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(BirthInformationRepositoryError.invalidUserID))
            return
        }

        documentReference(for: uid)
            .getDocument { snapshot, error in

                if let error {
                    completion(.failure(error))
                    return
                }

                guard let snapshot,
                      snapshot.exists,
                      let data = snapshot.data() else {
                    completion(.success(nil))
                    return
                }

                do {
                    let information = try self.makeBirthInformation(from: data)
                    completion(.success(information))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    // MARK: Save

    func save(
        _ information: BirthInformation,
        uid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !uid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(BirthInformationRepositoryError.invalidUserID))
            return
        }
        
        guard information.hasValidBirthDate else {
            completion(.failure(
                BirthInformationRepositoryError.invalidBirthDate
            ))
            return
        }

        guard information.hasValidBirthTimeState else {
            completion(.failure(
                BirthInformationRepositoryError.invalidBirthTime
            ))
            return
        }

        guard information.hasValidBirthPlace else {
            completion(.failure(
                BirthInformationRepositoryError.invalidBirthPlace
            ))
            return
        }

        var data: [String: Any] = [
            "birthDateISO": information.birthDateISO ?? "",
            "isBirthTimeUnknown": information.isBirthTimeUnknown,
            "schemaVersion": information.schemaVersion,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let birthTimeMinutes = information.birthTimeMinutes {

            let hour = birthTimeMinutes / 60
            let minute = birthTimeMinutes % 60

            let formattedBirthTime = String(
                format: "%02d:%02d",
                hour,
                minute
            )

            data["birthTime"] = formattedBirthTime
            data["birthTimeMinutes"] = birthTimeMinutes

        } else {
            data["birthTime"] = FieldValue.delete()
            data["birthTimeMinutes"] = FieldValue.delete()
        }

        if let birthPlace = information.birthPlace {
            data["birthPlace"] = makeBirthPlaceDictionary(from: birthPlace)
        }
        
        let reference = documentReference(for: uid)

        print(
            "🟠 FIREBASE PROJECT ID:",
            FirebaseApp.app()?.options.projectID ?? "bulunamadı"
        )

        print(
            "🟠 FIREBASE GOOGLE APP ID:",
            FirebaseApp.app()?.options.googleAppID ?? "bulunamadı"
        )

        print("🟣 BIRTH SAVE PATH:", reference.path)
        print("🟣 BIRTH SAVE DATA:", data)

        reference.setData(data, merge: true) { error in

            if let error {
                print("🔴 BIRTH SAVE ERROR:", error.localizedDescription)
                completion(.failure(error))
                return
            }

            print("🟢 BIRTH SAVE SUCCESS:", reference.path)

            reference.getDocument(source: .server) { snapshot, readError in

                if let readError {
                    print(
                        "🔴 BIRTH SERVER READ ERROR:",
                        readError.localizedDescription
                    )

                    completion(.failure(readError))
                    return
                }

                print(
                    "🟢 BIRTH SERVER DOCUMENT EXISTS:",
                    snapshot?.exists ?? false
                )

                print(
                    "🟢 BIRTH SERVER DATA:",
                    snapshot?.data() ?? [:]
                )

                completion(.success(()))
            }
        }
    }

    // MARK: Delete

    func delete(
        uid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !uid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(BirthInformationRepositoryError.invalidUserID))
            return
        }

        documentReference(for: uid)
            .delete { error in

                if let error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
    }
}

// MARK: - Firestore Decoding

private extension BirthInformationRepository {

        func makeBirthInformation(
            from data: [String: Any]
        ) throws -> BirthInformation {

            let birthDateISO = data["birthDateISO"] as? String

        let birthTimeMinutes = data["birthTimeMinutes"] as? Int
        let isBirthTimeUnknown =
            data["isBirthTimeUnknown"] as? Bool ?? false
        let schemaVersion =
            data["schemaVersion"] as? Int ?? 1

        var birthPlace: BirthPlace?

        if let placeData = data["birthPlace"] as? [String: Any] {
            birthPlace = try makeBirthPlace(from: placeData)
        }

        let information = BirthInformation(
            birthDateISO: birthDateISO,
            birthTimeMinutes: birthTimeMinutes,
            isBirthTimeUnknown: isBirthTimeUnknown,
            birthPlace: birthPlace,
            schemaVersion: schemaVersion
        )

        return information
    }

    func makeBirthPlace(
        from data: [String: Any]
    ) throws -> BirthPlace {

        guard let city = data["city"] as? String,
              !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw BirthInformationRepositoryError.missingCity
        }

        guard let country = data["country"] as? String,
              !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw BirthInformationRepositoryError.missingCountry
        }

        guard let latitude = numberValue(data["latitude"]),
              let longitude = numberValue(data["longitude"])
        else {
            throw BirthInformationRepositoryError.missingCoordinates
        }

        guard let timeZoneIdentifier =
                data["timeZoneIdentifier"] as? String,
              TimeZone(identifier: timeZoneIdentifier) != nil
        else {
            throw BirthInformationRepositoryError.invalidTimeZone
        }

        return BirthPlace(
            city: city,
            administrativeArea: data["administrativeArea"] as? String,
            country: country,
            countryCode: data["countryCode"] as? String,
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZoneIdentifier,
            placeIdentifier: data["placeIdentifier"] as? String
        )
    }

    func numberValue(_ value: Any?) -> Double? {
        if let double = value as? Double {
            return double
        }

        if let number = value as? NSNumber {
            return number.doubleValue
        }

        return nil
    }
}

// MARK: - Firestore Encoding

private extension BirthInformationRepository {

    func makeBirthPlaceDictionary(
        from place: BirthPlace
    ) -> [String: Any] {
        var data: [String: Any] = [
            "city": place.city,
            "country": place.country,
            "latitude": place.latitude,
            "longitude": place.longitude,
            "timeZoneIdentifier": place.timeZoneIdentifier
        ]

        if let administrativeArea = cleaned(place.administrativeArea) {
            data["administrativeArea"] = administrativeArea
        }

        if let countryCode = cleaned(place.countryCode) {
            data["countryCode"] = countryCode.uppercased()
        }

        if let placeIdentifier = cleaned(place.placeIdentifier) {
            data["placeIdentifier"] = placeIdentifier
        }

        return data
    }

    func cleaned(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }
}

// MARK: - Errors

enum BirthInformationRepositoryError: LocalizedError {

    case invalidUserID
    case invalidBirthDate
    case invalidBirthTime
    case invalidBirthPlace

    case missingCity
    case missingCountry
    case missingCoordinates
    case invalidTimeZone

    var errorDescription: String? {
        switch self {
        case .invalidUserID:
            return "Kullanıcı bilgisi bulunamadı."
            
        case .invalidBirthDate:
            return "Doğum tarihi bilgisi geçerli değil."

        case .invalidBirthTime:
            return "Doğum saati bilgisi geçerli değil."

        case .invalidBirthPlace:
            return "Doğum yeri bilgisi eksik veya geçerli değil."

        case .missingCity:
            return "Doğum yerinin şehir bilgisi bulunamadı."

        case .missingCountry:
            return "Doğum yerinin ülke bilgisi bulunamadı."

        case .missingCoordinates:
            return "Doğum yerinin koordinatları bulunamadı."

        case .invalidTimeZone:
            return "Doğum yerinin saat dilimi doğrulanamadı."
        }
    }
}
