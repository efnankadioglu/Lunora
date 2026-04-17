//
//  ProgressStorage.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 9.04.2026.
//

import Foundation

final class ProgressStorage {

    static let shared = ProgressStorage()
    private init() {}

    private let keyPrefix = "progress_"

    // SAVE
    func save(_ progress: UserProgramProgress) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(progress) {
            UserDefaults.standard.set(data, forKey: keyPrefix + progress.programId)
        }
    }

    // LOAD
    func load(programId: String) -> UserProgramProgress? {
        guard let data = UserDefaults.standard.data(forKey: keyPrefix + programId) else {
            return nil
        }
        return try? JSONDecoder().decode(UserProgramProgress.self, from: data)
    }

    // DELETE (opsiyonel)
    func clear(programId: String) {
        UserDefaults.standard.removeObject(forKey: keyPrefix + programId)
    }
}
