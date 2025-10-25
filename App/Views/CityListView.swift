//
//  CityListView.swift
//  App
//
//  Created by Atakan İçel on 20.10.2025.
//

import SwiftUI
import SwiftData

struct CityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cities: [WeatherCity]
    @State private var showingAddCity = false
    
    var body: some View {
        NavigationStack {
            List {
                if cities.isEmpty {
                    ContentUnavailableView(
                        "Henüz Şehir Eklenmedi",
                        systemImage: "cloud.sun.fill",
                        description: Text("Hava durumunu takip etmek için şehir ekleyin")
                    )
                } else {
                    ForEach(cities) { city in
                        CityRowView(city: city)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteCity(city)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    toggleSelection(city)
                                } label: {
                                    Label(
                                        city.isSelected ? "Seçimi Kaldır" : "Widget için Seç",
                                        systemImage: city.isSelected ? "star.fill" : "star"
                                    )
                                }
                                .tint(city.isSelected ? .orange : .blue)
                            }
                    }
                }
            }
            .navigationTitle("Hava Durumu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCity = true
                    } label: {
                        Label("Şehir Ekle", systemImage: "plus")
                    }
                }
                
                if !cities.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            refreshAllCities()
                        } label: {
                            Label("Yenile", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddCity) {
                AddCityView()
            }
        }
    }
    
    private func deleteCity(_ city: WeatherCity) {
        modelContext.delete(city)
    }
    
    private func toggleSelection(_ city: WeatherCity) {
        // Önce diğer tüm şehirlerin seçimini kaldır
        for otherCity in cities {
            otherCity.isSelected = false
        }
        // Seçili şehri işaretle
        city.isSelected = true
    }
    
    private func refreshAllCities() {
        for city in cities {
            // Simüle edilmiş hava durumu güncellemesi
            city.temperature = Double.random(in: -10...40)
            city.humidity = Int.random(in: 30...90)
            city.windSpeed = Double.random(in: 0...50)
            city.lastUpdated = Date()
        }
    }
}

struct CityRowView: View {
    let city: WeatherCity
    
    var body: some View {
        HStack(spacing: 16) {
            // Hava durumu ikonu
            Image(systemName: weatherIcon)
                .font(.system(size: 40))
                .foregroundStyle(weatherColor)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(city.name)
                        .font(.headline)
                    if city.isSelected {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Text(city.country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(city.condition)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(city.temperature))°C")
                    .font(.system(size: 32, weight: .bold))
                
                HStack(spacing: 8) {
                    Label("\(city.humidity)%", systemImage: "humidity.fill")
                    Label("\(Int(city.windSpeed)) km/h", systemImage: "wind")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
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

#Preview {
    CityListView()
        .modelContainer(ModelContainer.shared)
}

