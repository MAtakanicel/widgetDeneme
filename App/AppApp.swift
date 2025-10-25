//
//  AppApp.swift
//  App
//
//  Created by Atakan İçel on 20.10.2025.
//

import SwiftUI
import SwiftData

@main
struct AppApp: App {
    var body: some Scene {
        WindowGroup {
            CityListView()
        }
        .modelContainer(ModelContainer.shared)
    }
}
