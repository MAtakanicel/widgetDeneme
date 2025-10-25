//
//  WeatherCity.swift
//  App
//
//  Created by Atakan İçel on 20.10.2025.
//

import Foundation
import SwiftData

@Model
final class WeatherCity {
    var id: UUID
    var name: String
    var country: String
    var temperature: Double
    var condition: String
    var humidity: Int
    var windSpeed: Double
    var lastUpdated: Date
    var isSelected: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        temperature: Double,
        condition: String,
        humidity: Int,
        windSpeed: Double,
        lastUpdated: Date = Date(),
        isSelected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.temperature = temperature
        self.condition = condition
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.lastUpdated = lastUpdated
        self.isSelected = isSelected
    }
}

// Weather condition türleri
enum WeatherCondition: String, CaseIterable {
    case sunny = "Güneşli"
    case cloudy = "Bulutlu"
    case rainy = "Yağmurlu"
    case snowy = "Karlı"
    case stormy = "Fırtınalı"
    case foggy = "Sisli"
    case partlyCloudy = "Parçalı Bulutlu"
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.fill"
        case .foggy: return "cloud.fog.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        }
    }
}

