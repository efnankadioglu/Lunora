//
//  AstrologyService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.12.2025.
//

import Foundation

class AstrologyService {
    
    /// 1. JSON dosyasını yükleyip [DailyAstrology] listesine dönüştüren fonksiyon
    static func loadMonthlyData(fileName: String) -> [DailyAstrology]? {
        // Proje içine (Bundle) attığın JSON dosyasının yolunu bulur
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("HATA: \(fileName).json dosyası Resources klasöründe bulunamadı.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // JSON'daki 'moon_phase' gibi alt tireli isimleri Swift'teki 'moonPhase'e otomatik çevirir
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([DailyAstrology].self, from: data)
        } catch {
            print("HATA: JSON verisi çözümlenemedi: \(error)")
            return nil
        }
    }
    
    /// 2. Bugünün tarihini JSON formatında (yyyy-MM-dd) veren yardımcı fonksiyon
    static func getTodayDateString() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: today)
    }
    
    /// 3. Tarihe göre otomatik dosya seçip bugünün verisini getiren ana fonksiyon
    static func getAstrologyForToday() -> DailyAstrology? {
        let today = Date()
        let formatter = DateFormatter()
        
        // A) Telefonun ayına göre dosya ismini belirle (01, 02... 12)
        formatter.dateFormat = "MM"
        let currentMonth = formatter.string(from: today)
        let fileName = "astrology_data_2026_\(currentMonth)"
        
        // B) Bugünün tarih metnini al (2026-01-18 gibi)
        let todayString = getTodayDateString()
        
        // C) İlgili ayın dosyasını yükle ?????*????????????????
        guard let monthlyData = loadMonthlyData(fileName: fileName) else { return nil }
        
        // D) Liste içinden bugünün tarihine eşleşen veriyi bul
        return monthlyData.first(where: { $0.date == todayString })
    }
}
