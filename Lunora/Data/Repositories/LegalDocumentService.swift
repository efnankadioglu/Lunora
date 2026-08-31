//
//  LegalDocumentService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 30.08.2026.
//

import Foundation
import FirebaseFirestore

enum LegalDocumentType: String {

    case terms
    case privacy
    case kvkk

    var defaultTitle: String {

        switch self {

        case .terms:
            return "Kullanım Koşulları"

        case .privacy:
            return "Gizlilik Politikası"

        case .kvkk:
            return "KVKK Aydınlatma Metni"
        }
    }
}

struct LegalDocumentModel {

    let title: String
    let content: String
    let version: String
}

enum LegalDocumentError: LocalizedError {

    case documentNotFound
    case inactiveDocument

    var errorDescription: String? {

        switch self {

        case .documentNotFound:
            return "Belge şu anda yüklenemedi."

        case .inactiveDocument:
            return "Bu belge şu anda kullanılamıyor."
        }
    }
}

final class LegalDocumentService {

    static let shared = LegalDocumentService()

    private let db = Firestore.firestore()

    private init() {}

    func fetch(
        _ type: LegalDocumentType,
        completion: @escaping (
            Result<LegalDocumentModel, Error>
        ) -> Void
    ) {

        db.collection("legal_documents")
            .document(type.rawValue)
            .getDocument { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard
                    let snapshot = snapshot,
                    snapshot.exists,
                    let data = snapshot.data()
                else {
                    completion(
                        .failure(
                            LegalDocumentError.documentNotFound
                        )
                    )
                    return
                }

                let isActive =
                    data["isActive"] as? Bool ?? true

                guard isActive else {
                    completion(
                        .failure(
                            LegalDocumentError.inactiveDocument
                        )
                    )
                    return
                }

                guard
                    let content =
                        data["content"] as? String,
                    !content.isEmpty
                else {
                    completion(
                        .failure(
                            LegalDocumentError.documentNotFound
                        )
                    )
                    return
                }

                let title =
                    data["title"] as? String
                    ?? type.defaultTitle

                let version =
                    data["version"] as? String
                    ?? "1.0"

                let document =
                    LegalDocumentModel(
                        title: title,
                        content: content,
                        version: version
                    )

                completion(
                    .success(document)
                )
            }
    }
}
