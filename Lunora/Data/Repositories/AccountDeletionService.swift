//
//  AccountDeletionService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 22.07.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFunctions

final class AccountDeletionService {

    static let shared = AccountDeletionService()

    private lazy var functions = Functions.functions()

    private init() {}

    func deleteAccount(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard Auth.auth().currentUser != nil else {
            let error = NSError(
                domain: "Lunora",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Hesabını silmek için tekrar giriş yapmalısın."
                ]
            )

            completion(.failure(error))
            return
        }

        functions
            .httpsCallable("deleteUserAccount")
            .call { _, error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
