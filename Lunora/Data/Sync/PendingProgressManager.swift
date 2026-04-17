//
//  PendingProgressManager.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 17.04.2026.
//

import Foundation

final class PendingProgressManager {

    static let shared = PendingProgressManager()
    private init() {}

    private let storageKey = "pending_progress_actions"

    // MARK: - Save action
    func add(_ action: PendingProgressAction) {
        var actions = loadAll()
        actions.append(action)
        saveAll(actions)
        print("🟡 Pending action eklendi:", action.id)
    }

    // MARK: - Load
    func loadAll() -> [PendingProgressAction] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }

        return (try? JSONDecoder().decode([PendingProgressAction].self, from: data)) ?? []
    }

    // MARK: - Save
    private func saveAll(_ actions: [PendingProgressAction]) {
        if let data = try? JSONEncoder().encode(actions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Clear
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Remove single
    func remove(id: UUID) {
        var actions = loadAll()
        actions.removeAll { $0.id == id }
        saveAll(actions)
    }
}
