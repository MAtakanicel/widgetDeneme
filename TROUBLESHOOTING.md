# 🔧 Sorun Giderme Kılavuzu

Bu dokümanda, Hava Durumu Widget uygulamasında karşılaşabileceğiniz yaygın sorunlar ve çözümleri bulabilirsiniz.

## 📑 İçindekiler

1. [Derleme Hataları](#derleme-hataları)
2. [Widget Sorunları](#widget-sorunları)
3. [Veri Paylaşım Sorunları](#veri-paylaşım-sorunları)
4. [App Intent Sorunları](#app-intent-sorunları)
5. [Genel Sorunlar](#genel-sorunlar)

---

## Derleme Hataları

### ❌ "No such module 'SwiftData'"

**Neden:** iOS deployment target yeterince yüksek değil.

**Çözüm:**
1. Proje ayarlarını açın
2. Her iki target için (App ve WeatherWidget):
   - General > Minimum Deployments > iOS 17.0
3. Clean Build Folder (Cmd + Shift + K)
4. Rebuild (Cmd + B)

```
App Target:
├── General
│   └── Minimum Deployments: iOS 17.0

WeatherWidget Target:
├── General
│   └── Minimum Deployments: iOS 17.0
```

---

### ❌ "Cannot find 'WeatherCity' in scope"

**Neden:** Model dosyası widget target'ına eklenmemiş.

**Çözüm:**
1. `WeatherCity.swift` dosyasını seçin
2. File Inspector (sağ panel) açın
3. Target Membership bölümünde:
   - ✅ App
   - ✅ WeatherWidget
4. Aynısını `ModelContainer+Shared.swift` için yapın

---

### ❌ "Multiple commands produce..."

**Neden:** Aynı dosya birden fazla target'ta var ve çakışıyor.

**Çözüm:**
1. Duplicate dosyaları bulun
2. Gereksiz olanları silin
3. Clean Build Folder (Cmd + Shift + K)
4. Derived Data'yı silin:
   - Xcode > Preferences > Locations
   - Derived Data yoluna gidin
   - Klasörü silin

---

### ❌ "App Intents entitlement is required"

**Neden:** Widget Extension için App Intents yetkisi eksik.

**Çözüm:**
1. WeatherWidget target'ı seçin
2. Signing & Capabilities
3. Info.plist'e şunu ekleyin:
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
```

---

## Widget Sorunları

### ❌ Widget Ana Ekranda Görünmüyor

**Kontrol Listesi:**

1. **Widget Extension Düzgün Mü?**
   ```
   ✅ Target adı: WeatherWidget
   ✅ Bundle ID: com.yourname.App.WeatherWidget
   ✅ Deployment Target: iOS 17.0+
   ```

2. **Derleme Başarılı Mı?**
   - Hem App hem WeatherWidget başarıyla derlendi mi?
   - Console'da hata var mı?

3. **Widget Eklediniz Mi?**
   - Ana ekran > Long press > + > "Weather" ara

**Çözüm Adımları:**
```bash
1. Uygulamayı tamamen silin
2. Clean Build Folder (Cmd + Shift + K)
3. Derived Data'yı temizleyin
4. Yeniden build edin
5. Simülatörü/cihazı restart edin
6. Widget'ı yeniden ekleyin
```

---

### ❌ Widget Boş veya "No Widget" Gösteriyor

**Neden:** Veri yok veya App Group çalışmıyor.

**Adım 1: Ana Uygulamada Veri Var Mı?**
```swift
// Ana uygulamada şehir ekleyin
// En az 1 şehir olmalı
```

**Adım 2: Şehir Seçili Mi?**
```swift
// Bir şehri sola kaydırın
// "Widget için Seç" butonuna dokunun
// Yıldız ⭐ işareti görmeli
```

**Adım 3: App Groups Kontrolü**
```
Her iki target'ta da:
Signing & Capabilities > App Groups > group.com.weather.app
```

---

### ❌ Widget Güncellenmiyor

**Timeline Kontrolleri:**

1. **Timeline Policy:**
```swift
// WeatherWidget.swift içinde
let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
// nextUpdate = 15 dakika sonra
```

2. **Manuel Güncelleme:**
```swift
// Ana uygulamada veri değiştirdikten sonra
WidgetCenter.shared.reloadAllTimelines()
```

3. **Background Refresh:**
   - Settings > General > Background App Refresh > ON

**Hızlı Test:**
```
1. Widget'ı ana ekrandan kaldırın
2. Yeniden ekleyin
3. Ana uygulamada veri değiştirin
4. 1-2 dakika bekleyin
```

---

### ❌ Interactive Widget Butonu Çalışmıyor

**App Intent Kontrolleri:**

1. **Intent Tanımlı Mı?**
```swift
// RefreshWeatherIntent implement edilmiş mi?
struct RefreshWeatherIntent: AppIntent { ... }
```

2. **Button Doğru Kullanılmış Mı?**
```swift
Button(intent: RefreshWeatherIntent()) {
    Image(systemName: "arrow.clockwise")
}
```

3. **iOS Versiyon Kontrolü:**
   - Interactive widget iOS 17+ gerektirir
   - Simülatör/cihaz iOS 17.0+ olmalı

---

## Veri Paylaşım Sorunları

### ❌ Ana Uygulama ve Widget Farklı Veri Görüyor

**Root Cause:** App Group yapılandırması hatalı.

**Doğru Yapılandırma:**

```
App.entitlements:
<?xml version="1.0" encoding="UTF-8"?>
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.weather.app</string>
    </array>
</dict>

WeatherWidget.entitlements:
<?xml version="1.0" encoding="UTF-8"?>
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.weather.app</string>
    </array>
</dict>
```

**Kritik:** Her iki dosyada da TAM AYNI GROUP ID!

---

### ❌ SwiftData Container Hatası

**Hata Mesajı:** "Failed to load model container"

**Çözüm 1: Container Yapılandırması**
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,  // ⚠️ false olmalı
    groupContainer: .identifier("group.com.weather.app")  // ⚠️ Tam eşleşmeli
)
```

**Çözüm 2: Model Dosyaları**
```
✅ WeatherCity.swift her iki target'ta
✅ ModelContainer+Shared.swift her iki target'ta
✅ @Model macro doğru kullanılmış
```

**Debug:**
```swift
do {
    let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    print("✅ Container created successfully")
} catch {
    print("❌ Container error: \(error)")
}
```

---

## App Intent Sorunları

### ❌ Intent Çalışmıyor

**Checklist:**

```
✅ AppIntent protocol implement edilmiş
✅ static var title tanımlı
✅ perform() fonksiyonu var
✅ async throws kullanılmış
✅ IntentResult dönüyor
```

**Örnek:**
```swift
struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "Hava Durumunu Yenile"
    
    func perform() async throws -> some IntentResult {
        // İşlemler
        return .result()
    }
}
```

---

### ❌ Intent Container'a Erişemiyor

**Sorun:** Intent içinde SwiftData'ya erişilemiyor.

**Çözüm:**
```swift
func perform() async throws -> some IntentResult {
    // 1. Configuration oluştur
    let modelConfiguration = ModelConfiguration(
        schema: Schema([WeatherCity.self]),
        isStoredInMemoryOnly: false,
        groupContainer: .identifier("group.com.weather.app")
    )
    
    // 2. Container oluştur
    guard let container = try? ModelContainer(
        for: Schema([WeatherCity.self]),
        configurations: [modelConfiguration]
    ) else {
        return .result()
    }
    
    // 3. Context al
    let context = ModelContext(container)
    
    // 4. İşlemleri yap
    // ...
    
    return .result()
}
```

---

## Genel Sorunlar

### ❌ Simülatör'de Çalışıyor, Gerçek Cihazda Çalışmıyor

**Nedenler:**

1. **Signing Sorunu:**
   - Team seçili mi?
   - Provisioning profile doğru mu?
   - Her iki target için de signing yapıldı mı?

2. **Capabilities:**
   - App Groups her iki target'ta ekli mi?
   - Developer account'ta App Group oluşturuldu mu?

3. **Bundle ID:**
   - Unique mi?
   - Widget bundle ID, app bundle ID'nin alt grubu mu?
   ```
   App: com.yourname.WeatherApp
   Widget: com.yourname.WeatherApp.WeatherWidget
   ```

---

### ❌ Dark Mode'da Görünüm Bozuk

**Çözüm:**

```swift
// Renkleri dynamic yapın
.foregroundStyle(.primary)  // ❌ .black yerine
.foregroundStyle(.secondary)  // ❌ .gray yerine

// Background'lar
.containerBackground(for: .widget) {
    LinearGradient(...)
}
```

---

### ❌ Widget Performance Sorunları

**Optimizasyonlar:**

1. **Lightweight Timeline:**
```swift
// ❌ Kötü
let entries = (0..<100).map { ... }

// ✅ İyi
let entries = [currentEntry]
```

2. **Efficient Queries:**
```swift
// ✅ İyi - Filtered query
let descriptor = FetchDescriptor<WeatherCity>(
    predicate: #Predicate { $0.isSelected == true }
)

// ❌ Kötü - All data
let all = try context.fetch(FetchDescriptor<WeatherCity>())
```

3. **Image Sizes:**
```swift
// ✅ SF Symbols kullan
Image(systemName: "cloud.fill")

// ❌ Büyük custom image'lar kullanma
```

---

### ❌ Memory Warning

**Neden:** Widget çok fazla memory kullanıyor.

**Çözümler:**

1. **Entry'leri hafif tutun:**
```swift
struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: WeatherCity
    // ❌ Ekstra ağır data eklemeyin
}
```

2. **Image cache'i yönetin:**
```swift
// SF Symbols kullanın, custom image minimize edin
```

3. **Timeline entry sayısını sınırlandırın:**
```swift
// Sadece current entry
let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
```

---

## Debug Teknikleri

### Console Logging

```swift
// Widget'ta
print("🔍 [Widget] Timeline requested")
print("📊 [Widget] City: \(city.name), Temp: \(city.temperature)")

// Intent'te
print("⚡ [Intent] Refresh started")
```

### Breakpoint'ler

```
1. Timeline provider fonksiyonlarına breakpoint
2. App Intent perform() fonksiyonuna breakpoint
3. Model fetch operations'a breakpoint
```

### Widget Timeline Debug

```swift
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    print("⏰ Timeline at: \(Date())")
    print("📍 Context: \(context)")
    
    let entry = WeatherEntry(date: Date(), city: getSelectedCity() ?? defaultCity)
    print("📦 Entry created: \(entry)")
    
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    print("✅ Timeline completed")
    
    completion(timeline)
}
```

---

## Hızlı Çözüm Checklist

Sorun yaşadığınızda sırayla deneyin:

```
1. ☑️ Clean Build Folder (Cmd + Shift + K)
2. ☑️ Rebuild Project (Cmd + B)
3. ☑️ Restart Simulator/Device
4. ☑️ Delete App and Reinstall
5. ☑️ Check App Groups Configuration
6. ☑️ Check Target Memberships
7. ☑️ Check Bundle Identifiers
8. ☑️ Check Deployment Targets
9. ☑️ Clear Derived Data
10. ☑️ Restart Xcode
```

---

## Destek Kaynakları

### Apple Developer Forums
- [WidgetKit](https://developer.apple.com/forums/tags/widgetkit)
- [SwiftData](https://developer.apple.com/forums/tags/swiftdata)
- [App Intents](https://developer.apple.com/forums/tags/app-intents)

### Documentation
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [App Groups Guide](https://developer.apple.com/documentation/xcode/configuring-app-groups)

---

## İletişim

Sorun çözemediyseniz:

1. ✅ README.md'yi okuyun
2. ✅ SETUP_GUIDE.md'yi takip edin
3. ✅ TECHNICAL_DOCUMENTATION.md'yi inceleyin
4. ✅ Console log'larını kontrol edin
5. ✅ Xcode error mesajlarını okuyun

---

**Son Güncelleme:** 20 Ekim 2025
**Platform:** iOS 17.0+
**Xcode:** 15.0+

**Not:** Bu kılavuz sürekli güncellenmektedir. Yeni sorunlar bulursanız ekleyin!

