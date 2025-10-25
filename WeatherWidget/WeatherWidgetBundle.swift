//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Atakan İçel on 20.10.2025.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        InteractiveWeatherWidget()
    }
}
