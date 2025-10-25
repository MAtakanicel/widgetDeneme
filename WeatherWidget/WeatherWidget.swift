//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Atakan İçel on 20.10.2025.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
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
        
        // Widget'ı her 15 dakikada bir güncelle
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

struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: WeatherCity
}

struct WeatherWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWeatherWidget(city: entry.city)
        case .systemMedium:
            MediumWeatherWidget(city: entry.city)
        case .systemLarge:
            LargeWeatherWidget(city: entry.city)
        default:
            SmallWeatherWidget(city: entry.city)
        }
    }
}

// Küçük Widget (Küçük alan)
struct SmallWeatherWidget: View {
    let city: WeatherCity
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(city.country)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            
            Spacer()
            
            Image(systemName: weatherIcon)
                .font(.system(size: 40))
                .foregroundStyle(weatherColor)
            
            Text("\(Int(city.temperature))°C")
                .font(.system(size: 28, weight: .bold))
            
            Text(city.condition)
                .font(.caption)
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
        WeatherCondition.allCases.first(where: { $0.rawValue == city.condition })?.icon ?? "cloud.fill"
    }
    
    private var weatherColor: Color {
        switch city.condition {
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

// Orta Widget
struct MediumWeatherWidget: View {
    let city: WeatherCity
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.title2.bold())
                Text(city.country)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: weatherIcon)
                    .font(.system(size: 50))
                    .foregroundStyle(weatherColor)
                
                Text(city.condition)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                Text("\(Int(city.temperature))°C")
                    .font(.system(size: 48, weight: .bold))
                
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "humidity.fill")
                        Text("\(city.humidity)%")
                    }
                    .font(.caption)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "wind")
                        Text("\(Int(city.windSpeed)) km/h")
                    }
                    .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
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
        WeatherCondition.allCases.first(where: { $0.rawValue == city.condition })?.icon ?? "cloud.fill"
    }
    
    private var weatherColor: Color {
        switch city.condition {
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

// Büyük Widget
struct LargeWeatherWidget: View {
    let city: WeatherCity
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.title.bold())
                    Text(city.country)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Son Güncelleme")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 20) {
                Image(systemName: weatherIcon)
                    .font(.system(size: 80))
                    .foregroundStyle(weatherColor)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(city.temperature))°C")
                        .font(.system(size: 60, weight: .bold))
                    Text(city.condition)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Image(systemName: "humidity.fill")
                        .font(.title2)
                    Text("Nem")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(city.humidity)%")
                        .font(.title3.bold())
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "wind")
                        .font(.title2)
                    Text("Rüzgar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(city.windSpeed)) km/h")
                        .font(.title3.bold())
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "thermometer.medium")
                        .font(.title2)
                    Text("Hissedilen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(city.temperature - 2))°C")
                        .font(.title3.bold())
                }
            }
            .frame(maxWidth: .infinity)
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
        WeatherCondition.allCases.first(where: { $0.rawValue == city.condition })?.icon ?? "cloud.fill"
    }
    
    private var weatherColor: Color {
        switch city.condition {
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

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hava Durumu")
        .description("Seçili şehrin hava durumunu gösterir")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(
        date: .now,
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
