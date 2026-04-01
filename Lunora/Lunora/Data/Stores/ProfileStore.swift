//
//  ProfileStore.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 12.11.2025.
//
//
// Data/Stores/ProfileStore.swift

import UIKit
import CoreData

final class ProfileStore {
    static let shared = ProfileStore()
    private let context: NSManagedObjectContext

    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        // Unique Constraints (uid, username) ile uyumlu güvenli birleştirme
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Username availability (case-insensitive)
    func isUsernameAvailable(_ username: String, excluding uid: String? = nil) -> Bool {
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        if let uid = uid {
            req.predicate = NSPredicate(format: "username ==[c] %@ AND uid != %@", username, uid)
        } else {
            req.predicate = NSPredicate(format: "username ==[c] %@", username)
        }
        req.fetchLimit = 1
        do { return try context.count(for: req) == 0 } catch { return true }
    }

    // MARK: - Upsert & return
    @discardableResult
    func saveProfile(uid: String,
                     name: String,
                     username: String,
                     motivation: String,
                     avatar: UIImage?) throws -> UserProfile {

        // Varsa bu uid ile kaydı getir, yoksa yeni oluştur
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        req.predicate = NSPredicate(format: "uid == %@", uid)
        req.fetchLimit = 1

        let profile = try context.fetch(req).first ?? UserProfile(context: context)

        profile.uid = uid
        profile.name = name
        profile.username = username
        profile.motivation = motivation

        let finalImage = avatar ?? UIImage(named: "defaultAvatar")
        profile.avatarImageData = finalImage?.jpegData(compressionQuality: 0.85)

        try context.save()
        return profile
    }

    // MARK: - Fetch
    func fetchProfile(uid: String) -> UserProfile? {
        let req: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        req.predicate = NSPredicate(format: "uid == %@", uid)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

    // MARK: - (Opsiyonel) Hepsini sil – test için
    func deleteAllProfiles() throws {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "UserProfile")
        let batch = NSBatchDeleteRequest(fetchRequest: fetch)
        try context.execute(batch)
        try context.save()
    }
}
