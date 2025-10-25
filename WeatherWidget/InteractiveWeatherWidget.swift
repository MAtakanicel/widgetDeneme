//
//  InteractiveWeatherWidget.swift
//  WeatherWidget
//
//  Created by Atakan İçel on 20.10.2025.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// App Intent - Hava durumunu yenile
struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "Hava Durumunu Yenile"
    static var description = IntentDescription("Hava durumu verilerini günceller")
    
    func perform() async throws -> some IntentResult {
        // SwiftData container'a erişim
        let modelConfiguration = ModelConfiguration(
            schema: Schema([WeatherCity.self]),
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.weather.app")
        )
        
        guard let container = try? ModelContainer(
            for: Schema([WeatherCity.self]),
            configurations: [modelConfiguration]
        ) else {
            return .result()
        }
        
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<WeatherCity>(
            predicate: #Predicate { $0.isSelected == true }
        )
        
        if let selectedCity = try? context.fetch(descriptor).first {
            // Hava durumunu simüle et
            selectedCity.temperature = Double.random(in: -10...40)
            selectedCity.humidity = Int.random(in: 30...90)
            selectedCity.windSpeed = Double.random(in: 0...50)
            selectedCity.lastUpdated = Date()
            
            try? context.save()
        }
        
        return .result()
    }
}

// App Intent - Şehir değiştir
struct ChangeCityIntent: AppIntent {
    static var title: LocalizedStringResource = "Şehir Değiştir"
    static var description = IntentDescription("Widget'ta görüntülenen şehri değiştirir")
    
    @Parameter(title: "Şehir")
    var cityName: String
    
    func perform() async throws -> some IntentResult {
        let modelConfiguration = ModelConfiguration(
            schema: Schema([WeatherCity.self]),
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.weather.app")
        )
        
        guard let container = try? ModelContainer(
            for: Schema([WeatherCity.self]),
            configurations: [modelConfiguration]
        ) else {
            return .result()
        }
        
        let context = ModelContext(container)
        let allCitiesDescriptor = FetchDescriptor<WeatherCity>()
        
        if let cities = try? context.fetch(allCitiesDescriptor) {
            // Tüm şehirlerin seçimini kaldır
            for city in cities {
                city.isSelected = false
            }
            
            // Belirtilen şehri seç
            if let targetCity = cities.first(where: { $0.name == cityName }) {
                targetCity.isSelected = true
                try? context.save()
            }
        }
        
        return .result()
    }
}

// İnteraktif Widget Provider
struct InteractiveProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            city: WeatherCity(
                name: "İstanbul",
                country: "Türkiye",
                temperature: 22,
                condition: "Güneşli",
                humidity: 65,
                windSpeed: 15
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(
            date: Date(),
            city: getSelectedCity() ?? WeatherCity(
                name: "İstanbul",
                country: "Türkiye",
                temperature: 22,
                condition: "Güneşli",
                humidity: 65,
                windSpeed: 15
            )
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = WeatherEntry(
            date: currentDate,
            city: getSelectedCity() ?? WeatherCity(
                name: "Şehir Seç",
                country: "Ana uygulamadan şehir seçin",
                temperature: 0,
                condition: "Bulutlu",
                humidity: 0,
                windSpeed: 0
            )
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getSelectedCity() -> WeatherCity? {
        let modelConfiguration = ModelConfiguration(
            schema: Schema([WeatherCity.self]),
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.weather.app")
        )
        
        guard let container = try? ModelContainer(
            for: Schema([WeatherCity.self]),
            configurations: [modelConfiguration]
        ) else {
            return nil
        }
        
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<WeatherCity>(
            predicate: #Predicate { $0.isSelected == true }
        )
        
        return try? context.fetch(descriptor).first
    }
}

// İnteraktif Widget View
struct InteractiveWeatherWidgetView: View {
    var entry: InteractiveProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.city.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(entry.city.country)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                
                // Yenileme butonu
                Button(intent: RefreshWeatherIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            
            Spacer()
            
            Image(systemName: weatherIcon)
                .font(.system(size: 35))
                .foregroundStyle(weatherColor)
            
            Text("\(Int(entry.city.temperature))°C")
                .font(.system(size: 24, weight: .bold))
            
            Text(entry.city.condition)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Detaylar
            HStack(spacing: 16) {
                Label("\(entry.city.humidity)%", systemImage: "humidity.fill")
                Label("\(Int(entry.city.windSpeed)) km/h", systemImage: "wind")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [weatherColor.opacity(0.3), weatherColor.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var weatherIcon: String {
        WeatherCondition.allCases.first(where: { $0.rawValue == entry.city.condition })?.icon ?? "cloud.fill"
    }
    
    private var weatherColor: Color {
        switch entry.city.condition {
        case "Güneşli": return .orange
        case "Bulutlu", "Parçalı Bulutlu": return .gray
        case "Yağmurlu": return .blue
        case "Karlı": return .cyan
        case "Fırtınalı": return .purple
        case "Sisli": return .secondary
        default: return .primary
        }
    }
}

struct InteractiveWeatherWidget: Widget {
    let kind: String = "InteractiveWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InteractiveProvider()) { entry in
            InteractiveWeatherWidgetView(entry: entry)
        }
        .configurationDisplayName("Etkileşimli Hava Durumu")
        .description("Dokunarak yenileyebileceğiniz hava durumu widget'ı")
        .supportedFamilies([.systemSmall])
    }
}

