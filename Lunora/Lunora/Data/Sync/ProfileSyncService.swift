//
//  ProfileSyncService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 14.11.2025.
//

//import Foundation
//import UIKit
//import FirebaseFirestore
//
//final class ProfileSyncService {
//    static let shared = ProfileSyncService()
//    private init() {}
//
//    private let db = Firestore.firestore()
//
//    // MARK: - PUSH (local -> remote, sadece metin alanları)
//    func pushProfileToRemote(uid: String,
//                             name: String,
//                             username: String,
//                             motivation: String,
//                             avatar: UIImage?, // Avatar sadece local Core Data'da tutuluyor
//                             completion: @escaping (Error?) -> Void) {
//
//        let data: [String: Any] = [
//            "uid": uid,
//            "name": name,
//            "username": username,
//            "motivation": motivation,
//            "updatedAt": FieldValue.serverTimestamp()
//        ]
//
//        db.collection("profiles").document(uid).setData(data, merge: true) { error in
//            completion(error)
//        }
//    }
//
//    // MARK: - PULL (remote -> local, sadece metin alanları)
//    func pullProfileIfExists(uid: String,
//                             completion: @escaping (UserProfile?) -> Void) {
//
//        func finish(_ profile: UserProfile?) {
//            DispatchQueue.main.async {
//                completion(profile)
//            }
//        }
//
//        db.collection("profiles").document(uid).getDocument { snapshot, error in
//            if let _ = error {
//                finish(nil)
//                return
//            }
//
//            guard let data = snapshot?.data() else {
//                finish(nil)
//                return
//            }
//
//            let name = data["name"] as? String ?? ""
//            let username = data["username"] as? String ?? ""
//            let motivation = data["motivation"] as? String ?? ""
//
//            do {
//                // Avatar'ı uzaktan almıyoruz; burada nil veriyoruz,
//                // ProfileStore defaultAvatar kullanacak.
//                let profile = try ProfileStore.shared.saveProfile(
//                    uid: uid,
//                    name: name,
//                    username: username,
//                    motivation: motivation,
//                    avatar: nil
//                )
//                finish(profile)
//            } catch {
//                finish(nil)
//            }
//        }
//    }
//}

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage // ???? Yeni ekledik: Fotoğraf yüklemek için şart

final class ProfileSyncService {
    static let shared = ProfileSyncService()
    private init() {}

    private let db = Firestore.firestore()
    private let storage = Storage.storage() // ???? Yeni ekledik: Storage referansı

    // MARK: - PUSH (local -> remote)
    func pushProfileToRemote(uid: String,
                             name: String,
                             username: String,
                             motivation: String,
                             avatar: UIImage?, // ???? Artık bunu sadece yerelde değil, uzak sunucuda da tutacağız
                             completion: @escaping (Error?) -> Void) {

        // 1. Önce fotoğraf var mı kontrol edelim ????
        if let image = avatar, let imageData = image.jpegData(compressionQuality: 0.6) {
            
            // Storage üzerinde "profile_images/kullanici_id.jpg" yolunu oluşturuyoruz ????
            let storageRef = storage.reference().child("profile_images/\(uid).jpg")
            
            // Fotoğrafı yüklüyoruz ????
            storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Fotoğraf yüklendi, şimdi linkini (URL) alıyoruz ????
                storageRef.downloadURL { url, error in
                    guard let imageURL = url?.absoluteString else {
                        completion(error)
                        return
                    }
                    
                    // 2. Fotoğraf linkini de alarak Firestore'a kaydediyoruz ????
                    self?.saveToFirestore(uid: uid, name: name, username: username, motivation: motivation, imageURL: imageURL, completion: completion)
                }
            }
        } else {
            // Fotoğraf seçilmediyse veya hata varsa sadece metinleri kaydet ????
            saveToFirestore(uid: uid, name: name, username: username, motivation: motivation, imageURL: nil, completion: completion)
        }
    }

    // Firestore kayıt işlemini tekrar etmemek için yardımcı fonksiyon ????
    private func saveToFirestore(uid: String, name: String, username: String, motivation: String, imageURL: String?, completion: @escaping (Error?) -> Void) {
        
        var data: [String: Any] = [
            "uid": uid,
            "name": name,
            "username": username,
            "motivation": motivation,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Eğer fotoğraf URL'si varsa veriye ekle ????
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
            // Not: İstersen burada imageURL'i de çekip yerel Core Data'na kaydedebilirsin ????

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
