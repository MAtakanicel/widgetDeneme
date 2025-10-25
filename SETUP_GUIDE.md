# 🚀 Hızlı Kurulum Kılavuzu

Bu kılavuz, Hava Durumu Widget uygulamasını Xcode'da çalıştırabilmek için gerekli adımları içerir.

## 📋 Ön Hazırlık

- ✅ Xcode 15.0 veya üzeri
- ✅ iOS 17.0+ destekleyen bir simülatör veya cihaz
- ✅ Apple Developer hesabı (gerçek cihaz için)

## 🔧 Adım Adım Kurulum

### 1. Widget Extension Ekleme

Proje dosyaları hazır, ancak Xcode projesine Widget Extension target'ını manuel olarak eklemeniz gerekiyor.

#### Xcode'da:

1. **Projeyi Açın**
   - `App.xcodeproj` dosyasına çift tıklayın

2. **Widget Extension Ekleyin**
   - Menü: `File` > `New` > `Target...`
   - `Widget Extension` seçin
   - İleri'ye tıklayın

3. **Yapılandırma**
   ```
   Product Name: WeatherWidget
   Include Configuration Intent: ✅ İşaretlemeyin
   ```

4. **Scheme Onayı**
   - "Activate 'WeatherWidget' scheme now?" sorusuna **Cancel** deyin
   - (Ana uygulama scheme'ini aktif tutacağız)

### 2. Widget Dosyalarını Yapılandırma

Widget Extension oluşturulduğunda Xcode otomatik dosyalar oluşturur. Bunları bizim dosyalarımızla değiştireceğiz.

#### Oluşturulan Dosyaları Silin:

1. Xcode sol panelde `WeatherWidget` klasörünü bulun
2. Xcode'un oluşturduğu şu dosyaları silin (Move to Trash):
   - `WeatherWidget.swift` (Xcode'un oluşturduğu)
   - `WeatherWidgetBundle.swift` (Xcode'un oluşturduğu)

#### Bizim Dosyalarımızı Ekleyin:

1. Xcode'da `WeatherWidget` klasörüne sağ tıklayın
2. `Add Files to "App"...` seçin
3. Şu dosyaları seçin ve ekleyin:
   ```
   WeatherWidget/
   ├── WeatherWidget.swift
   ├── WeatherWidgetBundle.swift
   ├── InteractiveWeatherWidget.swift
   ├── Info.plist
   └── WeatherWidget.entitlements
   ```

4. **ÖNEMLİ:** "Add to targets" kısmında **sadece WeatherWidget** işaretli olsun

### 3. Model Dosyalarını Paylaşma

Widget'ın SwiftData modellerine erişmesi için model dosyalarını her iki target'a da eklememiz gerekiyor.

1. Xcode'da `App/Models/WeatherCity.swift` dosyasını seçin
2. Sağ panelde (File Inspector) `Target Membership` bölümünü bulun
3. Hem **App** hem de **WeatherWidget** işaretli olmalı ✅

4. Aynı işlemi `ModelContainer+Shared.swift` için de yapın

### 4. App Groups Yapılandırması

Uygulama ve widget arasında veri paylaşımı için App Groups gereklidir.

#### Ana Uygulama için:

1. Xcode'da proje ayarlarını açın (mavi proje ikonu)
2. **App** target'ını seçin
3. `Signing & Capabilities` tab'ine gidin
4. `+ Capability` butonuna tıklayın
5. `App Groups` seçin
6. `+` butonuna tıklayıp şunu ekleyin:
   ```
   group.com.weather.app
   ```

#### Widget için:

1. Aynı yerde **WeatherWidget** target'ını seçin
2. `Signing & Capabilities` tab'inde
3. `+ Capability` > `App Groups`
4. Aynı grubu ekleyin:
   ```
   group.com.weather.app
   ```

### 5. Bundle Identifier Yapılandırması

1. **App** target için:
   ```
   Bundle Identifier: com.yourname.App
   ```

2. **WeatherWidget** target için:
   ```
   Bundle Identifier: com.yourname.App.WeatherWidget
   ```

⚠️ **ÖNEMLİ:** Widget bundle identifier, ana uygulama bundle identifier'ın alt grubu olmalıdır!

### 6. Signing Yapılandırması

#### Simülatör için:
- `Automatically manage signing` işaretli olmalı
- Team seçimi yapın

#### Gerçek Cihaz için:
- Apple Developer hesabınızla giriş yapın
- Provisioning Profile oluşturun
- Her iki target için de signing yapılandırın

### 7. Deployment Target Kontrolü

Her iki target için de minimum deployment target'ı kontrol edin:

1. **App** target > `General` > `Minimum Deployments`
   ```
   iOS 17.0
   ```

2. **WeatherWidget** target > `General` > `Minimum Deployments`
   ```
   iOS 17.0
   ```

## ▶️ Uygulamayı Çalıştırma

### Ana Uygulamayı Çalıştırma

1. Scheme'i seçin: **App**
2. Simülatör veya cihaz seçin
3. `Cmd + R` veya Play butonuna basın

### İlk Kullanım

1. Uygulama açıldığında boş liste göreceksiniz
2. Sağ üstteki `+` butonuna dokunun
3. Birkaç şehir ekleyin:
   - İstanbul, Türkiye (Güneşli, 25°C)
   - Ankara, Türkiye (Bulutlu, 18°C)
   - İzmir, Türkiye (Parçalı Bulutlu, 28°C)

4. Bir şehri widget için seçin:
   - Şehir üzerinde **sola** kaydırın
   - `⭐ Widget için Seç` butonuna dokunun

## 🔧 Widget Ekleme

### Ana Ekrana Widget Ekleme

1. **Simülatör/Cihazda:**
   - Ana ekranda boş bir alana uzun basın (edit mode)
   - Sol üstteki `+` butonuna dokunun
   - Arama kutusuna "Weather" yazın
   - Widget'ı bulup boyut seçin
   - `Add Widget` deyin

2. **Widget Boyutları:**
   - **Küçük (Small):** Temel bilgiler + yenileme butonu
   - **Orta (Medium):** Detaylı bilgiler
   - **Büyük (Large):** Tam detaylı görünüm

### İki Farklı Widget Türü

1. **Hava Durumu** (Normal)
   - Tüm boyutları destekler
   - Otomatik güncelleme

2. **Etkileşimli Hava Durumu** (Interactive)
   - Sadece küçük boyut
   - Yenileme butonu var
   - Dokunarak güncelleme

## 🧪 Test Etme

### Widget'ı Test Edin

1. Widget'ı ana ekrana ekleyin
2. Ana uygulamada şehir bilgilerini güncelleyin
3. Widget'ın güncellenmesini bekleyin (max 15 dk)
4. Etkileşimli widget'ta yenileme butonuna dokunun

### Etkileşimli Özellikleri Test Edin

1. Küçük etkileşimli widget ekleyin
2. Widget üzerindeki yenileme butonuna dokunun
3. Verilerin değiştiğini görün
4. Ana uygulamayı açıp değişiklikleri kontrol edin

## ❗ Sık Karşılaşılan Sorunlar ve Çözümleri

### Problem: "No such module 'SwiftData'"
**Çözüm:** 
- Build Settings > Minimum Deployments > iOS 17.0 olmalı
- Clean Build Folder (Cmd + Shift + K)
- Rebuild (Cmd + B)

### Problem: Widget görünmüyor
**Çözüm:**
1. App Groups'un her iki target'ta da ekli olduğunu kontrol edin
2. Group ID'nin tam olarak aynı olduğunu doğrulayın
3. Uygulamayı silip yeniden yükleyin
4. Simülatörü restart edin

### Problem: Veri paylaşılmıyor
**Çözüm:**
1. Model dosyalarının her iki target'ta da olduğunu kontrol edin
2. App Group ID'nin her yerde aynı olduğunu doğrulayın:
   ```
   group.com.weather.app
   ```
3. Entitlements dosyalarını kontrol edin

### Problem: Build hatası
**Çözüm:**
1. Clean Build Folder (Cmd + Shift + K)
2. Derived Data'yı silin:
   - Xcode > Preferences > Locations
   - Derived Data klasörünü silin
3. Xcode'u yeniden başlatın

### Problem: Widget güncellenmiyor
**Çözüm:**
1. Simülatör/Cihazı yeniden başlatın
2. Widget'ı kaldırıp yeniden ekleyin
3. Background App Refresh'in açık olduğunu kontrol edin

## 🎯 Kontrol Listesi

Kurulum tamamlandığında şunları doğrulayın:

- [ ] Ana uygulama başarıyla çalışıyor
- [ ] Şehir ekleyebiliyorum
- [ ] Şehir silebiliyorum
- [ ] Şehir seçebiliyorum (widget için)
- [ ] Widget ana ekrana eklenebiliyor
- [ ] Widget seçili şehri gösteriyor
- [ ] Widget verileri güncel
- [ ] Etkileşimli widget yenileme butonu çalışıyor
- [ ] Küçük, orta ve büyük widget boyutları çalışıyor

## 📞 Destek

Sorun yaşarsanız:

1. Bu kılavuzu baştan kontrol edin
2. README.md'deki "Sık Karşılaşılan Sorunlar" bölümüne bakın
3. Xcode Console'da hata mesajlarını kontrol edin

## 🎉 Başarılı Kurulum!

Tüm adımları tamamladıysanız, artık:
- ✅ SwiftData ile çalışan bir hava durumu uygulamanız
- ✅ Üç farklı boyutta widget'ınız
- ✅ App Intents ile etkileşimli özellikleriniz
- ✅ App Groups ile veri paylaşımınız

Hazırsınız! 🚀

---

**Son Güncelleme:** 20 Ekim 2025
**Xcode Versiyonu:** 15.0+
**iOS Versiyonu:** 17.0+

