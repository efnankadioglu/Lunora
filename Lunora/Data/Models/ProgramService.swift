//
//  ProgramService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.03.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class ProgramService {
    static let shared = ProgramService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: - Program Başlatma (14 Gün Kontrolü Dahil)
    func canStartProgram(programId: String, completion: @escaping (Bool, String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Kullanıcının bu programdaki geçmişine bakıyoruz
        db.collection("users").document(uid).collection("programHistory")
            .document(programId).getDocument { snapshot, error in
                
                if let data = snapshot?.data(), let lastDate = (data["lastInteractionDate"] as? Timestamp)?.dateValue() {
                    let daysSinceLast = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
                    
                    if daysSinceLast < 14 {
                        completion(false, "Bu programa tekrar başlamak için \(14 - daysSinceLast) gün daha beklemelisin.")
                        return
                    }
                }
                completion(true, nil)
            }
    }

    // MARK: - 24 Saat ve %50 Kontrolü (Check-up)
    func checkProgramStatus(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userProgRef = db.collection("users").document(uid).collection("activeProgram").document("current")
        
        userProgRef.getDocument { snapshot, _ in
            guard let data = snapshot?.data(), let lastInteraction = (data["lastInteractionDate"] as? Timestamp)?.dateValue() else { return }
            
            let hoursInactivity = Calendar.current.dateComponents([.hour], from: lastInteraction, to: Date()).hour ?? 0
            let dailyProgress = data["currentDayProgress"] as? Double ?? 0.0
            
            // KRİTİK KONTROLLER:
            // 1. 24 saat işlem yapılmadıysa VEYA 2. Gün bittiğinde %50 tamamlanmadıysa (Gün geçiş mantığına göre)
            if hoursInactivity >= 24 || (hoursInactivity >= 23 && dailyProgress < 50.0) {
                userProgRef.updateData([
                    "status": ProgramStatus.failed.rawValue, // 🔥 BURASI DEĞİŞTİ
                    "isFailed": true
                ])
                completion(false) // Program yandı!
            } else {
                completion(true)
            }
        }
    }

    // MARK: - Programı Başarıyla Bitirme ve Not Kaydı
    func finishProgram(successNote: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userProgRef = db.collection("users").document(uid).collection("activeProgram").document("current")
        
        userProgRef.getDocument { snapshot, _ in
            let totalPercent = snapshot?.data()?["progressPercent"] as? Double ?? 0.0
            
            if totalPercent >= 80.0 {
                // BAŞARILI: Rozet kazanır ve not kaydedilir
                let finalData: [String: Any] = [
                    "status": "completed",
                    "successNote": successNote,
                    "completedAt": FieldValue.serverTimestamp(),
                    "earnedBadge": true
                ]
                userProgRef.updateData(finalData, completion: completion)
            } else {
                // GENEL BAŞARI %80 ALTI: Program biter ama rozet yok
                userProgRef.updateData(["status": "finished_without_badge"], completion: completion)
            }
        }
    }
    func calculateProgress(totalDays: Int, totalTasksForDay: Int, completedTasksCount: Int, completedDaysCount: Int) -> (dailyPercent: Double, totalPercent: Double) {
        
        // 1. Günlük Yüzde Hesaplama
        // Her günün kendi içinde %100 olduğunu varsayalım (Baraj kontrolü için)
        let dailyPercent = (Double(completedTasksCount) / Double(totalTasksForDay)) * 100.0
        
        // 2. Genel Program Yüzdesi Hesaplama
        // Senin örneğin: 20 gün -> her gün %5. Her gün 5 görev -> her görev %1.
        let weightPerDay = 100.0 / Double(totalDays) // Her günün ağırlığı (%5)
        let weightPerTask = weightPerDay / Double(totalTasksForDay) // Her görevin genel toplama etkisi (%1)
        
        // Genel Toplam = (Tamamlanan Günler * Gün Ağırlığı) + (Bugünkü Görevler * Görev Ağırlığı)
        let totalPercent = (Double(completedDaysCount) * weightPerDay) + (Double(completedTasksCount) * weightPerTask)
        
        return (dailyPercent, totalPercent)
    }
    // MARK: - Görev Tamamlandığında Veritabanını Güncelle
        func updateTaskProgress(totalDays: Int, totalTasksForDay: Int, completedTasksCount: Int, completedDaysCount: Int, completion: @escaping (Error?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            // 1. Senin yazdığın o harika matematik fonksiyonunu çağırıyoruz
            let results = calculateProgress(
                totalDays: totalDays,
                totalTasksForDay: totalTasksForDay,
                completedTasksCount: completedTasksCount,
                completedDaysCount: completedDaysCount
            )
            
            // 2. Firebase'e bu sonuçları yazıyoruz
            let updateData: [String: Any] = [
                "currentDayProgress": results.dailyPercent, // Bugünkü %50 barajı için
                "progressPercent": results.totalPercent,    // Genel %80 rozet hedefi için
                "lastInteractionDate": FieldValue.serverTimestamp() // 24 saat kuralı için saati sıfırlıyoruz
            ]
            
            db.collection("users").document(uid)
              .collection("activeProgram").document("current")
              .updateData(updateData) { error in
                  completion(error)
              }
        }
}
