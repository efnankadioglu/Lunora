//
//  ProgramCompletionPolicy.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 14.08.2026.
//

import Foundation

enum ProgramCompletionPolicy {

    /// Rozet kazanmak için gerekli minimum genel program ilerlemesi.
    static let badgeUnlockPercent: Double = 80.0

    /// Finalization sisteminin versiyonu.
    static let finalizationVersion: Int = 1
}

enum EnrollmentCompletionTrigger: String {

    /// Kullanıcı son gün son zorunlu görevi tamamladı.
    case lastTask = "last_task"

    /// Programın takvim süresi sona erdi.
    case durationEnded = "duration_ended"
}
