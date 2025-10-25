//
//  ModelContainer+Shared.swift
//  App
//
//  Created by Atakan İçel on 20.10.2025.
//

import SwiftData
import Foundation

extension ModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            WeatherCity.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.weather.app")
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            return container
        } catch {
            fatalError("ModelContainer oluşturulamadı: \(error)")
        }
    }()
}

