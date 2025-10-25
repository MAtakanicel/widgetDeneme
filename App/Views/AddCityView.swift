//
//  AddCityView.swift
//  App
//
//  Created by Atakan İçel on 20.10.2025.
//

import SwiftUI
import SwiftData

struct AddCityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var cityName = ""
    @State private var country = "Türkiye"
    @State private var temperature = 20.0
    @State private var selectedCondition = WeatherCondition.sunny
    @State private var humidity = 60
    @State private var windSpeed = 10.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Şehir Bilgileri") {
                    TextField("Şehir Adı", text: $cityName)
                    TextField("Ülke", text: $country)
                }
                
                Section("Hava Durumu") {
                    Picker("Durum", selection: $selectedCondition) {
                        ForEach(WeatherCondition.allCases, id: \.self) { condition in
                            HStack {
                                Image(systemName: condition.icon)
                                Text(condition.rawValue)
                            }
                            .tag(condition)
                        }
                    }
                    
                    HStack {
                        Text("Sıcaklık")
                        Spacer()
                        Text("\(Int(temperature))°C")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $temperature, in: -20...50, step: 1)
                    
                    HStack {
                        Text("Nem")
                        Spacer()
                        Text("\(humidity)%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: Binding(
                        get: { Double(humidity) },
                        set: { humidity = Int($0) }
                    ), in: 0...100, step: 5)
                    
                    HStack {
                        Text("Rüzgar Hızı")
                        Spacer()
                        Text("\(Int(windSpeed)) km/h")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $windSpeed, in: 0...100, step: 5)
                }
            }
            .navigationTitle("Yeni Şehir Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        addCity()
                    }
                    .disabled(cityName.isEmpty || country.isEmpty)
                }
            }
        }
    }
    
    private func addCity() {
        let newCity = WeatherCity(
            name: cityName,
            country: country,
            temperature: temperature,
            condition: selectedCondition.rawValue,
            humidity: humidity,
            windSpeed: windSpeed
        )
        
        modelContext.insert(newCity)
        dismiss()
    }
}

#Preview {
    AddCityView()
        .modelContainer(ModelContainer.shared)
}

