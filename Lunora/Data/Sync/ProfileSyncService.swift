//
//  ProfileSyncService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 14.11.2025.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

final class ProfileSyncService {
    static let shared = ProfileSyncService()
    private init() {}

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - PUSH (local -> remote)
    func pushProfileToRemote(uid: String,
                             name: String,
                             username: String,
                             motivation: String,
                             avatar: UIImage?,
                             completion: @escaping (Error?) -> Void) {

        if let image = avatar, let imageData = image.jpegData(compressionQuality: 0.6) {

            let storageRef = storage.reference().child("profile_images/\(uid).jpg")

            storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
                if let error = error {
                    completion(error)
                    return
                }

                storageRef.downloadURL { url, error in
                    guard let imageURL = url?.absoluteString else {
                        completion(error)
                        return
                    }
 
                    self?.saveToFirestore(uid: uid, name: name, username: username, motivation: motivation, imageURL: imageURL, completion: completion)
                }
            }
        } else {
            saveToFirestore(uid: uid, name: name, username: username, motivation: motivation, imageURL: nil, completion: completion)
        }
    }

    private func saveToFirestore(uid: String, name: String, username: String, motivation: String, imageURL: String?, completion: @escaping (Error?) -> Void) {
        
        var data: [String: Any] = [
            "uid": uid,
            "name": name,
            "username": username,
            "motivation": motivation,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        if let url = imageURL {
            data["profileImageURL"] = url
        }

        db.collection("profiles").document(uid).setData(data, merge: true) { error in
            completion(error)
        }
    }

    // MARK: - PULL (remote -> local)
    func pullProfileIfExists(uid: String,
                             completion: @escaping (UserProfile?) -> Void) {

        func finish(_ profile: UserProfile?) {
            DispatchQueue.main.async {
                completion(profile)
            }
        }

        db.collection("profiles").document(uid).getDocument { snapshot, error in
            if let _ = error {
                finish(nil)
                return
            }

            guard let data = snapshot?.data() else {
                finish(nil)
                return
            }

            let name = data["name"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            let motivation = data["motivation"] as? String ?? ""
            do {
                let profile = try ProfileStore.shared.saveProfile(
                    uid: uid,
                    name: name,
                    username: username,
                    motivation: motivation,
                    avatar: nil
                )
                finish(profile)
            } catch {
                finish(nil)
            }
        }
    }
}
