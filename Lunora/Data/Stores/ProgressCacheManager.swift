//
//  ProgressCacheManager.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 13.04.2026.
//

import Foundation

final class ProgressCacheManager {
    static let shared = ProgressCacheManager()
    private init() {}
    
    private let storageKey = "progress_cache"
    
    func save(_ cache: ProgressCache) {
        do {
            let data = try JSONEncoder().encode(cache)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("🔴 Progress cache save hatası:", error.localizedDescription)
        }
    }
    
    func load() -> ProgressCache? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        
        do {
            let cache = try JSONDecoder().decode(ProgressCache.self, from: data)
            return cache
        } catch {
            print("🔴 Progress cache load hatası:", error.localizedDescription)
            return nil
        }
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    func loadLatest() -> ProgressCache? {
        let defaults = UserDefaults.standard

        for key in defaults.dictionaryRepresentation().keys {
            if key.contains("progress_cache_") {
                if let data = defaults.data(forKey: key),
                   let cache = try? JSONDecoder().decode(ProgressCache.self, from: data) {
                    return cache
                }
            }
        }
        return nil
    }
}
