//
//  MockProgramSkyCompatibilityProvider.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.08.2026.
//

import Foundation

final class MockProgramSkyCompatibilityProvider {

    func compatibility(
        for program: Program
    ) -> ProgramSkyCompatibility {

        return ProgramSkyCompatibility(
            status: .supportive,
            title: "Bugünün gökyüzü bu programı destekliyor",
            description: """
            Bugünün temaları içe dönüş, geçmişi gözden geçirme ve iletişim kalıplarını fark etme çalışmalarını destekliyor.
            """,
            matchedItems: [
                ProgramSkyCompatibilityItem(
                    id: "mercury_retrograde",
                    title: "Merkür Retrosu",
                    symbol: "☿"
                ),

                ProgramSkyCompatibilityItem(
                    id: "emotional_reflection",
                    title: "Duygusal Farkındalık",
                    symbol: "☾"
                )
            ]
        )
    }
}
