//
//  AstrologyRepository.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 1.04.2026.
//

import Foundation

final class AstrologyRepository {

    private let skyService = SkyService()

    func fetchDailyAstrology(
        for date: String,
        localFileName: String,
        completion: @escaping (Result<DailyAstrology, Error>) -> Void
    ) {

        // 1) Önce Firestore dene
        skyService.fetchSkyDay(for: date) { result in
            switch result {
            case .success(let item):
                print("✅ Veri Firestore'dan geldi")
                completion(.success(item))

            case .failure(let firestoreError):
                print("⚠️ Firestore başarısız oldu: \(firestoreError.localizedDescription)")
                print("📦 Local JSON fallback çalışıyor...")

                // 2) Firestore olmazsa local JSON
                guard let monthlyData = AstrologyService.loadMonthlyData(fileName: localFileName) else {
                    let error = NSError(
                        domain: "AstrologyRepository",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Ne Firestore ne de local JSON verisi okunamadı."]
                    )
                    completion(.failure(error))
                    return
                }

                guard let item = monthlyData.first(where: { $0.date == date }) else {
                    let error = NSError(
                        domain: "AstrologyRepository",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Local JSON içinde bu tarih bulunamadı."]
                    )
                    completion(.failure(error))
                    return
                }

                print("✅ Veri local JSON'dan geldi")
                completion(.success(item))
            }
        }
    }
}
