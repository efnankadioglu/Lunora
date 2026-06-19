//
//  ProgramStatus.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.03.2026.
//

import Foundation

enum ProgramStatus: String {
    case active              // Program devam ediyor
    case atRisk// 24 saat sınırı yaklaştı veya %50 altı (Görsel uyarı için)
    case failed              // Kural ihlali nedeniyle yandı
    case completed           // %80 başarı ile bitti
    case coolingDown// 14 günlük nadas süresi
    case notStarted          // Henüz hiç başlanmadı
}

struct StatusTheme {
    let colorName: String
    let iconName: String
    let message: String
}
