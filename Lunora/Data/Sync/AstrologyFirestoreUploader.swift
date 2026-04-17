//
//  AstrologyFirestoreUploader.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 1.04.2026.
//

import Foundation
import FirebaseFirestore

final class AstrologyFirestoreUploader {
    
    private let db = Firestore.firestore()
    
    func uploadAstrologyData(fileName: String) {
        
        guard let items = AstrologyService.loadMonthlyData(fileName: fileName) else {
            print("JSON okunamadı ❌")
            return
        }
        
        for item in items {
            
            let data: [String: Any] = [
                "date": item.date,
                "moon_phase": item.moonPhase,
                "daily_comment": item.dailyComment,
                "celestial_events": item.celestialEvents,
                "suitability_score": item.suitabilityScore,
                "moon_sign": item.moonSign
            ]
            
            db.collection("sky_days")
                .document(item.date)
                .setData(data) { error in
                    if let error = error {
                        print("Hata ❌:", error.localizedDescription)
                    } else {
                        print("Yüklendi ✅:", item.date)
                    }
                }
        }
    }
}
