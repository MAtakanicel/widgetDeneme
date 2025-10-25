# 📖 Teknik Dokümantasyon

## İçindekiler
1. [SwiftData Yapısı](#swiftdata-yapısı)
2. [WidgetKit Implementasyonu](#widgetkit-implementasyonu)
3. [App Intents](#app-intents)
4. [Veri Akışı](#veri-akışı)
5. [Mimari Kararlar](#mimari-kararlar)

---

## SwiftData Yapısı

### Model Tanımı

```swift
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
}
```

#### Özellikler:

- **@Model Macro:** SwiftData'nın model sınıfını otomatik olarak yapılandırır
- **Value Types:** Tüm özellikler value type (veya Codable)
- **isSelected:** Widget için hangi şehrin gösterileceğini belirler
- **UUID:** Her şehir için benzersiz tanımlayıcı

### ModelContainer Yapılandırması

```swift
extension ModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([WeatherCity.self])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.weather.app")
        )
        
        return try! ModelContainer(for: schema, configurations: [modelConfiguration])
    }()
}
```

#### Kritik Noktalar:

1. **Shared Container:** Singleton pattern ile tek bir container
2. **Group Container:** Widget ile veri paylaşımı
3. **Persistent Storage:** isStoredInMemoryOnly = false
4. **Schema Definition:** Model tipleri belirtilir

### Veri Erişimi

#### Ana Uygulamada:

```swift
@Environment(\.modelContext) private var modelContext
@Query private var cities: [WeatherCity]

// Veri ekleme
modelContext.insert(newCity)

// Veri silme
modelContext.delete(city)

// Otomatik kayıt (SwiftUI view update'lerinde)
```

#### Widget'ta:

```swift
let context = ModelContext(container)
let descriptor = FetchDescriptor<WeatherCity>(
    predicate: #Predicate { $0.isSelected == true }
)
let selectedCity = try? context.fetch(descriptor).first
```

---

## WidgetKit Implementasyonu

### Widget Yaşam Döngüsü

```
1. placeholder(in:) - Widget yüklenirken gösterilen placeholder
2. getSnapshot(in:) - Widget Gallery'de gösterilen anlık görüntü
3. getTimeline(in:) - Widget'ın zaman çizelgesi
```

### TimelineProvider Detayı

```swift
struct Provider: TimelineProvider {
    // Placeholder - Widget henüz yüklenmeden
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(), city: defaultCity)
    }
    
    // Snapshot - Widget seçim ekranında
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(date: Date(), city: getSelectedCity() ?? defaultCity)
        completion(entry)
    }
    
    // Timeline - Widget'ın güncellenme planı
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = WeatherEntry(date: currentDate, city: getSelectedCity() ?? defaultCity)
        
        // 15 dakika sonra güncelle
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}
```

### Timeline Entry

```swift
struct WeatherEntry: TimelineEntry {
    let date: Date        // Timeline için gerekli
    let city: WeatherCity // Widget'ta gösterilecek veri
}
```

### Widget Yapılandırması

```swift
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
```

### Widget Boyutları ve Layout

#### Small Widget (küçük alan, öz bilgi)
```swift
struct SmallWeatherWidget: View {
    // Şehir adı
    // Hava durumu ikonu
    // Sıcaklık
    // Durum
}
```

#### Medium Widget (orta alan, detay)
```swift
struct MediumWeatherWidget: View {
    // Small widget + 
    // Nem oranı
    // Rüzgar hızı
    // Daha büyük layout
}
```

#### Large Widget (geniş alan, tüm detaylar)
```swift
struct LargeWeatherWidget: View {
    // Medium widget +
    // Hissedilen sıcaklık
    // Son güncelleme zamanı
    // Divider ve düzenli layout
}
```

---

## App Intents

### Intent Yapısı

```swift
struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "Hava Durumunu Yenile"
    static var description = IntentDescription("Hava durumu verilerini günceller")
    
    func perform() async throws -> some IntentResult {
        // 1. Container'a erişim
        // 2. Seçili şehri bul
        // 3. Verileri güncelle
        // 4. Context'i kaydet
        return .result()
    }
}
```

### Intent Kullanımı

Widget'ta button ile:
```swift
Button(intent: RefreshWeatherIntent()) {
    Image(systemName: "arrow.clockwise")
}
```

### Intent Özellikleri

1. **Async/Await:** Modern concurrency
2. **Lightweight:** Widget içinde çalışır
3. **Background Execution:** Uygulama açık olmadan çalışabilir
4. **AppIntentResult:** Intent sonucunu döner

### ChangeCityIntent

```swift
struct ChangeCityIntent: AppIntent {
    @Parameter(title: "Şehir")
    var cityName: String
    
    func perform() async throws -> some IntentResult {
        // Tüm şehirleri al
        // Seçimi kaldır
        // Yeni şehri seç
        // Kaydet
    }
}
```

---

## Veri Akışı

### Ana Uygulama → Widget

```
1. Kullanıcı ana uygulamada şehir ekler
   ↓
2. SwiftData ModelContext'e insert edilir
   ↓
3. App Group Container'a kaydedilir
   ↓
4. Widget Timeline Policy'ye göre güncellenir (max 15 dk)
   ↓
5. Widget yeni veriyi gösterir
```

### Widget → Ana Uygulama

```
1. Kullanıcı widget'ta yenileme butonuna basar
   ↓
2. RefreshWeatherIntent tetiklenir
   ↓
3. Intent App Group Container'dan veri okur
   ↓
4. Veriyi günceller ve kaydeder
   ↓
5. Timeline yeniden oluşturulur
   ↓
6. Widget güncellenir
```

### Veri Senkronizasyonu

```swift
// App Group sayesinde aynı container
App:     ModelContainer.shared (group.com.weather.app)
Widget:  ModelContainer.shared (group.com.weather.app)
         ↓
      SQLite Database
      (Shared Container)
```

---

## Mimari Kararlar

### 1. Neden SwiftData?

**Artıları:**
- Modern Swift API
- @Model macro ile kolay model tanımı
- @Query ile otomatik UI güncellemesi
- App Group ile widget desteği
- Type-safe sorgular

**Alternatiflere Göre:**
- Core Data: Daha karmaşık, eski API
- UserDefaults: Sınırlı veri yapısı
- File System: Manuel encoding/decoding

### 2. Neden App Groups?

Widget ve ana uygulama farklı process'lerde çalışır:
- Ayrı sandbox'lar
- Veri paylaşımı için App Groups gerekli
- Container sharing ile SQLite database paylaşımı

### 3. Timeline Policy

```swift
.after(nextUpdate)  // Belirtilen tarihte güncelle
```

**Alternatifler:**
- `.atEnd`: Son entry bitince güncelle
- `.never`: Sadece manual güncelleme

**Seçim Nedeni:** Düzenli güncelleme için

### 4. Widget Families

3 boyut destekleniyor:
- **systemSmall:** Hızlı bilgi
- **systemMedium:** Detaylı bilgi
- **systemLarge:** Tam detay

**Neden 3'ü de?**
- Kullanıcı tercihi
- Farklı use case'ler
- Apple best practices

### 5. Singleton ModelContainer

```swift
static let shared: ModelContainer
```

**Nedenleri:**
- Performans (tek container)
- Veri tutarlılığı
- Thread safety
- SwiftData önerisi

---

## Performans Optimizasyonları

### 1. Query Optimizasyonu

```swift
// İyi ✅
let descriptor = FetchDescriptor<WeatherCity>(
    predicate: #Predicate { $0.isSelected == true }
)

// Kötü ❌
let allCities = try context.fetch(FetchDescriptor<WeatherCity>())
let selected = allCities.first(where: { $0.isSelected })
```

### 2. Timeline Budget

Widget'lar günlük güncelleme limiti:
- Timeline entry sayısını sınırlı tut
- Background refresh'i optimize et
- Gereksiz yenileme yapma

### 3. Memory Management

```swift
// Widget hafif olmalı
struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: WeatherCity  // Sadece gerekli veri
    // ❌ Büyük image'lar ekleme
    // ❌ Fazla computed property
}
```

---

## Güvenlik ve Privacy

### 1. App Groups

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.weather.app</string>
</array>
```

- Sadece aynı team ID'li uygulamalar
- Sandboxed environment
- Encrypted storage

### 2. Veri Güvenliği

- Tüm veriler cihazda
- Network kullanılmıyor (bu örnekte)
- iCloud backup (kullanıcı tercihine göre)

---

## Testing Stratejisi

### 1. Unit Tests

```swift
// Model tests
func testWeatherCityCreation() {
    let city = WeatherCity(name: "Test", ...)
    XCTAssertNotNil(city)
}

// Container tests
func testModelContainerCreation() {
    XCTAssertNotNil(ModelContainer.shared)
}
```

### 2. Widget Tests

```swift
// Timeline tests
func testTimelineProvider() {
    let provider = Provider()
    let expectation = XCTestExpectation()
    
    provider.getTimeline(in: context) { timeline in
        XCTAssertFalse(timeline.entries.isEmpty)
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5)
}
```

### 3. App Intent Tests

```swift
func testRefreshIntent() async throws {
    let intent = RefreshWeatherIntent()
    let result = try await intent.perform()
    // Assert result
}
```

---

## Debugging İpuçları

### 1. Widget Log'lama

```swift
print("🔍 [Widget] Selected city: \(city.name)")
```

Xcode Console'da görüntüle:
- Filter: "Widget"
- Device Console

### 2. Timeline Debug

```swift
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    print("⏰ Timeline requested at \(Date())")
    // ...
}
```

### 3. SwiftData Debug

```swift
do {
    let cities = try context.fetch(descriptor)
    print("📊 Fetched \(cities.count) cities")
} catch {
    print("❌ Error: \(error)")
}
```

---

## Best Practices

### ✅ DO

1. **Lightweight Entries:** Widget entry'leri hafif tutun
2. **Error Handling:** Her zaman error handling yapın
3. **Placeholder:** Anlamlı placeholder'lar kullanın
4. **Timeline Budget:** Güncelleme limitlerini gözetin
5. **Consistent Data:** Veri tutarlılığını koruyun

### ❌ DON'T

1. **Heavy Computation:** Widget'ta ağır işlem yapmayın
2. **Network Calls:** Timeline'da network call yapmayın
3. **Large Images:** Büyük görseller kullanmayın
4. **Frequent Updates:** Çok sık güncelleme yapmayın
5. **Complex Logic:** Widget view'da kompleks logic yazmayın

---

## Sonuç

Bu proje şunları gösterir:

1. ✅ Modern SwiftData kullanımı
2. ✅ WidgetKit implementasyonu
3. ✅ App Intents entegrasyonu
4. ✅ App Groups veri paylaşımı
5. ✅ Responsive widget tasarımı
6. ✅ Best practices uygulaması

**Öğrenme Hedefleri:**
- SwiftData @Model ve @Query
- WidgetKit TimelineProvider
- App Intents async/await
- App Groups yapılandırması
- Widget UI/UX tasarımı

---

**Geliştirici Notları:**

Bu dokümantasyon, projenin teknik detaylarını açıklar. Kurulum için `SETUP_GUIDE.md` dosyasına, genel bilgi için `README.md` dosyasına bakınız.

**Son Güncelleme:** 20 Ekim 2025

