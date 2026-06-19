//
//  AstrologyService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.12.2025.
//

import Foundation

class AstrologyService {
    
    static let astrologyFileName = "astrology_data_2026_06_08"
    
    /// JSON dosyasını yükleyip [DailyAstrology] listesine dönüştüren fonksiyon
    static func loadMonthlyData(fileName: String) -> [DailyAstrology]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("HATA: \(fileName).json dosyası Resources klasöründe bulunamadı.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([DailyAstrology].self, from: data)
        } catch {
            print("HATA: JSON verisi çözümlenemedi: \(error)")
            return nil
        }
    }
    
    /// Bugünün tarihini JSON formatında verir: yyyy-MM-dd
    static func getTodayDateString() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return formatter.string(from: today)
    }
    
    /// Tek JSON dosyasından bugünün verisini getirir
    static func getAstrologyForToday() -> DailyAstrology? {
        let todayString = getTodayDateString()
        
        guard let astrologyData = loadMonthlyData(fileName: astrologyFileName) else {
            return nil
        }
        
        let todayData = astrologyData.first(where: { $0.date == todayString })
        
        if todayData == nil {
            print("UYARI: \(todayString) tarihi için astroloji verisi bulunamadı.")
        }
        
        return todayData
    }
    
    /// Test için belirli bir tarihi getirir
    static func getAstrology(for dateString: String) -> DailyAstrology? {
        guard let astrologyData = loadMonthlyData(fileName: astrologyFileName) else {
            return nil
        }
        
        return astrologyData.first(where: { $0.date == dateString })
    }
}
