//
//  ProgramLoader.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.01.2026.
//

import Foundation

final class ProgramLoader {

    static func loadPrograms() -> [Program] {
        guard let url = Bundle.main.url(forResource: "programs_data", withExtension: "json") else {
            print("❌ programs_data.json Bundle içinde bulunamadı")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(ProgramResponse.self, from: data)
            return decoded.programs
        } catch {
            print("❌ JSON decode hatası:", error)
            return []
        }
    }
}
