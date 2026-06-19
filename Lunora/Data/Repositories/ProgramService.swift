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
    
    // MARK: - Firestore'dan Programları Çek
    func fetchPrograms(completion: @escaping ([Program]) -> Void) {
        db.collection("programs")
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Firestore program okuma hatası: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("❌ Firestore program document bulunamadı")
                    completion([])
                    return
                }
                
                print("🧪 Firestore toplam document sayısı:", documents.count)
                
                let decodedPrograms: [(sortOrder: Int, program: Program)] = documents.compactMap { document in
                    do {
                        var data = document.data()
                        
                        if data["id"] == nil {
                            data["id"] = document.documentID
                        }
                        
                        data.removeValue(forKey: "updatedAt")
                        data.removeValue(forKey: "createdAt")
                        
                        let sortOrder = data["sortOrder"] as? Int ?? 999
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let program = try JSONDecoder().decode(Program.self, from: jsonData).formatted()
                        
                        return (sortOrder: sortOrder, program: program)
                        
                    } catch {
                        print("❌ Program decode edilemedi")
                        print("❌ Document ID:", document.documentID)
                        print("❌ Error:", error.localizedDescription)
                        print("❌ Raw data:", document.data())
                        return nil
                    }
                }
                
                let activePrograms = decodedPrograms
                    .filter { $0.program.isActive == true }
                    .sorted { $0.sortOrder < $1.sortOrder }
                    .map { $0.program }
                
                print("✅ Firestore aktif program sayısı:", activePrograms.count)
                completion(activePrograms)
            }
    }
 
    
    // MARK: - Program Başlatma (14 Gün Kontrolü Dahil)
    func canStartProgram(programId: String, completion: @escaping (Bool, String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("programHistory")
            .document(programId).getDocument { snapshot, error in
                
                if let data = snapshot?.data(),
                   let lastDate = (data["lastInteractionDate"] as? Timestamp)?.dateValue() {
                    
                    let daysSinceLast = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
                    
                    if daysSinceLast < 14 {
                        completion(false, "Bu programa tekrar başlamak için \(14 - daysSinceLast) gün daha beklemelisin.")
                        return
                    }
                }
                
                completion(true, nil)
            }
    }

    // MARK: - 24 Saat ve %50 Kontrolü
    func checkProgramStatus(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userProgRef = db.collection("users").document(uid).collection("activeProgram").document("current")
        
        userProgRef.getDocument { snapshot, _ in
            guard let data = snapshot?.data(),
                  let lastInteraction = (data["lastInteractionDate"] as? Timestamp)?.dateValue() else {
                return
            }
            
            let hoursInactivity = Calendar.current.dateComponents([.hour], from: lastInteraction, to: Date()).hour ?? 0
            let dailyProgress = data["currentDayProgress"] as? Double ?? 0.0
            
            if hoursInactivity >= 24 || (hoursInactivity >= 23 && dailyProgress < 50.0) {
                userProgRef.updateData([
                    "status": ProgramStatus.failed.rawValue,
                    "isFailed": true
                ])
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // MARK: - Programı Başarıyla Bitirme
    func finishProgram(successNote: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userProgRef = db.collection("users").document(uid).collection("activeProgram").document("current")
        
        userProgRef.getDocument { snapshot, _ in
            let totalPercent = snapshot?.data()?["progressPercent"] as? Double ?? 0.0
            
            if totalPercent >= 80.0 {
                let finalData: [String: Any] = [
                    "status": "completed",
                    "successNote": successNote,
                    "completedAt": FieldValue.serverTimestamp(),
                    "earnedBadge": true
                ]
                userProgRef.updateData(finalData, completion: completion)
            } else {
                userProgRef.updateData(["status": "finished_without_badge"], completion: completion)
            }
        }
    }

    // MARK: - Yüzde Hesaplama
    func calculateProgress(
        totalDays: Int,
        totalTasksForDay: Int,
        completedTasksCount: Int,
        completedDaysCount: Int
    ) -> (dailyPercent: Double, totalPercent: Double) {
        
        let dailyPercent = (Double(completedTasksCount) / Double(totalTasksForDay)) * 100.0
        
        let weightPerDay = 100.0 / Double(totalDays)
        let weightPerTask = weightPerDay / Double(totalTasksForDay)
        
        let totalPercent = (Double(completedDaysCount) * weightPerDay) + (Double(completedTasksCount) * weightPerTask)
        
        return (dailyPercent, totalPercent)
    }

    // MARK: - Görev Tamamlandığında Veritabanını Güncelle
    func updateTaskProgress(
        totalDays: Int,
        totalTasksForDay: Int,
        completedTasksCount: Int,
        completedDaysCount: Int,
        completion: @escaping (Error?) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let results = calculateProgress(
            totalDays: totalDays,
            totalTasksForDay: totalTasksForDay,
            completedTasksCount: completedTasksCount,
            completedDaysCount: completedDaysCount
        )
        
        let updateData: [String: Any] = [
            "currentDayProgress": results.dailyPercent,
            "progressPercent": results.totalPercent,
            "lastInteractionDate": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid)
            .collection("activeProgram").document("current")
            .updateData(updateData) { error in
                completion(error)
            }
    }
}
