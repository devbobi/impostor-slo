# 🕵️ Impostor SLO

Družabna party igra tipa *social deduction* (v slogu Spyfall) — **v slovenščini**, za en telefon in skupino prijateljev (»pass & play«).

Večina igralcev pozna skrivno besedo. Eden (ali več) je **impostor** in besede ne pozna — poskuša blefirati in ostati neopažen. Ostali z namigi ugotavljajo, kdo se pretvarja.

## ✨ Značilnosti

- 🇸🇮 Popolnoma v slovenščini (vmesnik in besede).
- 📱 Način **pass & play** — potrebujete le en telefon, brez interneta.
- 👥 3–10 igralcev, 1–3 impostorji.
- 🗂️ 5 kategorij besed (hrana, poklici, filmi/serije, živali, kraji v Sloveniji).
- ⏱️ Nastavljiv časovnik za krog namigovanja.
- 🎴 Animirano razkritje vloge (flip karta).
- 🌙 Temna, party-friendly tema.

## 🎮 Potek igre

1. **Priprava** — izberi število igralcev, kategorijo in število impostorjev.
2. **Razkritje** — telefon kroži; vsak na skrivaj pogleda svojo vlogo/besedo.
3. **Namigovanje** — vsak po vrsti pove en namig, povezan z besedo (opcijski časovnik).
4. **Glasovanje** — izberete, koga izločite.
5. **Razplet** — če ujamete impostorja, zmagajo navadni; sicer zmaga impostor.

## 🛠️ Tehnologija

- **Flutter** (Dart) — gladke animacije, majhna velikost, kasnejši port na iOS.
- **Riverpod** — upravljanje stanja.
- Besede shranjene lokalno v `assets/data/besede.json`.

Arhitektura je modularna, tako da je mogoče kasneje dodati:
- **online multiplayer** (npr. Firebase Firestore, sistem sob s kodo),
- **dodatne jezike** (lokalizacija prek `intl`/ARB).

## 🚀 Zagon (razvoj)

Potrebuješ nameščen [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.19).

```bash
# 1. Kloniraj repozitorij
git clone https://github.com/devbobi/impostor-slo.git
cd impostor-slo

# 2. Ustvari platformske mape (android/ios) — potrebno enkrat
flutter create .

# 3. Namesti odvisnosti
flutter pub get

# 4. Zaženi na priključeni napravi ali emulatorju
flutter run
```

> Datoteke v `lib/`, `assets/`, `test/`, `pubspec.yaml` so že v repozitoriju.
> `flutter create .` samo dogenerira `android/` in `ios/` ovojnico ter jih ne prepiše.

## 📦 Izgradnja APK za Android

```bash
flutter build apk --release
```

Datoteka nastane v `build/app/outputs/flutter-apk/app-release.apk` — prenesi jo na telefon in namesti (dovoli namestitev iz neznanih virov).

## 🧪 Testi in analiza

```bash
flutter analyze
flutter test
```

## 🗺️ Načrt (roadmap)

- [ ] Vnos imen igralcev (namesto »Igralec 1, 2 …«).
- [ ] Več besed in kategorij + uporabniške (custom) kategorije.
- [ ] Zvočni učinki in vibracije.
- [ ] Online multiplayer s kodo sobe.
- [ ] Večjezičnost.

## 📄 Licenca

MIT — glej [LICENSE](LICENSE).
