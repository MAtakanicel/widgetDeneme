# 🌤️ Hava Durumu Widget Uygulaması

Bu proje, **WidgetKit**, **App Intents** ve **SwiftData** teknolojilerini kullanarak geliştirilmiş modern bir iOS hava durumu uygulamasıdır.

## 📋 Özellikler

### Ana Uygulama
- ✅ Şehir ekleme, düzenleme ve silme
- ✅ SwiftData ile veri yönetimi
- ✅ Widget için şehir seçimi
- ✅ Hava durumu bilgilerini yenileme
- ✅ Modern ve kullanıcı dostu arayüz

### Widget Özellikleri
- 🎯 **3 Farklı Boyut:** Küçük, Orta ve Büyük widget desteği
- 🔄 **Etkileşimli Widget:** Doğrudan widget'tan yenileme
- 📱 **App Intents:** Widget üzerinden etkileşimli işlemler
- 🔁 **Otomatik Güncelleme:** Her 15 dakikada bir otomatik yenileme
- 🎨 **Dinamik Renk Şeması:** Hava durumuna göre değişen renkler

## 🛠️ Kullanılan Teknolojiler

### SwiftUI
Modern ve deklaratif UI framework'ü kullanılarak tüm arayüz geliştirildi.

### SwiftData
- Veri modelleme için `@Model` macro
- App Group ile uygulama ve widget arası veri paylaşımı
- ModelContainer yapılandırması
- FetchDescriptor ile veri sorgulama

### WidgetKit
- **StaticConfiguration:** Widget yapılandırması
- **TimelineProvider:** Widget güncellemeleri
- **Widget Families:** systemSmall, systemMedium, systemLarge desteği
- **Timeline Policy:** Otomatik güncelleme stratejisi

### App Intents
- **RefreshWeatherIntent:** Hava durumunu yenileme
- **ChangeCityIntent:** Şehir değiştirme
- Widget'lardan doğrudan etkileşim

## 📦 Proje Yapısı

```
App/
├── App/
│   ├── AppApp.swift                    # Ana uygulama entry point
│   ├── ContentView.swift               # Ana view
│   ├── Models/
│   │   ├── WeatherCity.swift          # SwiftData modeli
│   │   └── ModelContainer+Shared.swift # Paylaşılan container
│   ├── Views/
│   │   ├── CityListView.swift         # Şehir listesi
│   │   └── AddCityView.swift          # Şehir ekleme ekranı
│   └── App.entitlements               # Ana uygulama yetkileri
│
└── WeatherWidget/
    ├── WeatherWidgetBundle.swift       # Widget bundle
    ├── WeatherWidget.swift             # Ana widget
    ├── InteractiveWeatherWidget.swift  # Etkileşimli widget
    ├── Assets.xcassets/                # Widget assets
    ├── Info.plist                      # Widget yapılandırması
    └── WeatherWidget.entitlements      # Widget yetkileri
```

## 🎨 Widget Tasarımı

### Küçük Widget (Small)
- Şehir adı ve ülke
- Hava durumu ikonu
- Sıcaklık
- Durum açıklaması

### Orta Widget (Medium)
- Küçük widget'taki tüm bilgiler
- Nem oranı
- Rüzgar hızı
- Daha geniş layout

### Büyük Widget (Large)
- Orta widget'taki tüm bilgiler
- Hissedilen sıcaklık
- Son güncelleme zamanı
- Detaylı hava durumu göstergeleri

## 🔄 Etkileşimli Özellikler

### 1. Hava Durumunu Yenileme
Widget üzerindeki yenileme butonuna dokunarak anlık güncelleme yapabilirsiniz.

**Teknik Detay:**
```swift
struct RefreshWeatherIntent: AppIntent {
    func perform() async throws -> some IntentResult {
        // SwiftData'dan seçili şehri al
        // Hava durumu verilerini güncelle
        // Widget timeline'ı güncelle
    }
}
```

### 2. Şehir Değiştirme
Ana uygulamadan widget için görüntülenecek şehri seçebilirsiniz.

**Kullanım:**
- Şehir listesinde sola kaydırın
- "Widget için Seç" butonuna dokunun
- Widget otomatik olarak güncellenecektir

## 💾 Veri Paylaşımı

### App Group Yapılandırması
Uygulama ve widget arasında veri paylaşımı için **App Group** kullanılır.

**Group ID:** `group.com.weather.app`

**ModelContainer Yapılandırması:**
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    groupContainer: .identifier("group.com.weather.app")
)
```

Bu sayede:
- Ana uygulamadan eklenen şehirler widget'ta görünür
- Widget'tan yapılan güncellemeler uygulamaya yansır
- Veriler güvenli şekilde paylaşılır

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+

### Adımlar

1. **Widget Extension'ı Projeye Ekleyin**
   - Xcode'da: File > New > Target
   - Widget Extension seçin
   - İsim: "WeatherWidget"
   - Finish'e tıklayın

2. **Dosyaları İçe Aktarın**
   - Tüm dosyaları doğru klasörlere yerleştirin
   - Target Membership'leri kontrol edin

3. **App Group Yapılandırması**
   - Ana uygulama Target > Signing & Capabilities
   - "+ Capability" > "App Groups"
   - "group.com.weather.app" ekleyin
   - Widget Target için aynı işlemi tekrarlayın

4. **Model Dosyalarını Widget'a Ekleyin**
   - `WeatherCity.swift` ve `ModelContainer+Shared.swift`
   - Widget target'ına dahil edin (Target Membership)

5. **Projeyi Derleyin ve Çalıştırın**
   ```bash
   # Ana uygulamayı çalıştırın
   Cmd + R
   
   # Widget'ı test edin
   Scheme seçimi: WeatherWidget
   ```

## 📱 Kullanım Kılavuzu

### Şehir Ekleme
1. Ana ekranda sağ üstteki "+" butonuna dokunun
2. Şehir bilgilerini girin
3. Hava durumu parametrelerini ayarlayın
4. "Ekle" butonuna dokunun

### Widget Ekleme
1. Ana ekranda boş bir alana uzun basın
2. Sol üstteki "+" butonuna dokunun
3. "Hava Durumu" widget'ını bulun
4. İstediğiniz boyutu seçin
5. "Add Widget" butonuna dokunun

### Widget Yapılandırması
1. Ana uygulamada bir şehir ekleyin
2. Şehrin üzerinde sola kaydırın
3. "Widget için Seç" butonuna dokunun
4. Widget otomatik olarak güncellenecektir

### Etkileşimli Widget Kullanımı
1. Küçük boyutta "Etkileşimli Hava Durumu" widget'ını ekleyin
2. Widget üzerindeki yenileme butonuna dokunun
3. Veriler anında güncellenecektir

## 🎯 Widget Nasıl Çalışır?

### Timeline Provider
Widget'lar **Timeline Provider** kullanarak güncellenir:

```swift
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ())
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ())
}
```

### Güncelleme Stratejisi
- **Otomatik:** Her 15 dakikada bir
- **Manuel:** App Intent ile
- **Background:** SwiftData değişikliklerinde

### Entry Yapısı
```swift
struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: WeatherCity
}
```

## 🔐 Güvenlik ve Yetkiler

### Entitlements
- App Groups: Veri paylaşımı için
- Widget Extension: Widget desteği için

### Privacy
- Konum servisleri kullanılmamaktadır
- Tüm veriler cihazda saklanır
- İnternet bağlantısı gerekmez (simüle edilmiş veriler)

## 🎨 Tasarım Prensipleri

### Renk Sistemi
- Dinamik renk paleti
- Hava durumuna özel renkler
- Dark mode desteği

### Tipografi
- SF Pro sistem fontu
- Dinamik tip desteği
- Okunabilirlik optimizasyonu

### Layout
- Responsive tasarım
- Safe area desteği
- Tüm cihaz boyutlarında uyumluluk

## 🧪 Test Senaryoları

### Ana Uygulama
- [x] Şehir ekleme
- [x] Şehir silme
- [x] Şehir seçimi
- [x] Veri güncelleme

### Widget
- [x] Küçük widget görünümü
- [x] Orta widget görünümü
- [x] Büyük widget görünümü
- [x] Timeline güncellemesi
- [x] App Intent çalışması

### Entegrasyon
- [x] App Group veri paylaşımı
- [x] Widget-App senkronizasyonu
- [x] Background güncelleme

## 📈 Geliştirme Notları

### SwiftData Kullanımı
- `@Model` macro ile model tanımlama
- `@Query` ile otomatik veri çekme
- ModelContext ile veri manipülasyonu

### Widget Best Practices
- Timeline Entry hafif tutuldu
- Ağır işlemler background'da
- Placeholder view implementasyonu

### App Intents Implementasyonu
- Basit ve odaklı intentler
- Async/await yapısı
- Error handling

## 🔮 Gelecek Geliştirmeler

- [ ] Gerçek hava durumu API entegrasyonu
- [ ] Konum bazlı otomatik şehir ekleme
- [ ] 7 günlük tahmin
- [ ] Saatlik hava durumu grafiği
- [ ] Live Activity desteği
- [ ] Dynamic Island entegrasyonu
- [ ] Push notification'lar
- [ ] Çoklu şehir widget desteği

## 📚 Kaynaklar

### Apple Documentation
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [App Intents](https://developer.apple.com/documentation/appintents)

### WWDC Sessions
- WWDC23: Meet SwiftData
- WWDC23: Bring widgets to life
- WWDC23: Dive deeper into App Intents

## 👨‍💻 Geliştirici

**Atakan İçel**
- Proje Tarihi: 20 Ekim 2025
- Platform: iOS 17+
- Framework: SwiftUI + WidgetKit

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

---

## 🆘 Sık Karşılaşılan Sorunlar

### Widget görünmüyor
- App Group yapılandırmasını kontrol edin
- Target Membership'leri kontrol edin
- Uygulamayı yeniden derleyin

### Veri paylaşılmıyor
- App Group ID'nin her iki target'ta da aynı olduğundan emin olun
- ModelContainer yapılandırmasını kontrol edin

### Widget güncellenmiyor
- Timeline Policy'yi kontrol edin
- Background App Refresh'in açık olduğundan emin olun

---

**Not:** Bu proje WidgetKit, App Intents ve SwiftData teknolojilerini öğrenmek için geliştirilmiş örnek bir uygulamadır. Hava durumu verileri simüle edilmiştir ve gerçek API entegrasyonu içermemektedir.

