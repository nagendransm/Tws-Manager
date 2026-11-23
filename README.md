# TWS Manager (Mivi DuoPods K2 Companion App)

A specialized Android mobile application built with Flutter to manage, monitor, and customize True Wireless Stereo (TWS) earphones, tailored for the **Mivi DuoPods K2**.

---

## 🎧 Mivi DuoPods K2 Specifications & Features

| Specification | Details |
| :--- | :--- |
| **Driver Size** | 13mm Electroplated Dynamic Drivers (punchy bass, clear vocals, sharp highs) |
| **Bluetooth Version** | Bluetooth v5.3 (10m range, energy-efficient, fast pairing) |
| **Audio Codecs** | AAC, SBC |
| **Total Playtime** | Up to **40 Hours** (earbuds + charging case) |
| **Earbud Playtime** | ~8 Hours continuous playback per charge |
| **Swift / Fast Charging** | **10 minutes charge = 500 minutes (~8.3 hours)** playtime |
| **Charging Port** | USB Type-C |
| **ANC (Active Noise Cancellation)** | **N/A** (Uses passive in-ear silicone isolation seal) |
| **ENC (Environmental Noise)** | **AI-ENC** with **Dual HD Microphones** for clear voice calls |
| **Low Latency Gaming** | **50ms Battle Mode** (Triple-tap activation) |
| **Water Resistance** | IPX4 (Sweat and splash resistant) |
| **Dual Device Connection** | Yes (Seamless switching between phone and laptop) |
| **Touch Controls** | Adaptive Touch Sensors (Tap, Double-tap, Triple-tap, Long-press) |
| **Origin** | Made in India |

---

## 📱 Mobile App Features

### 1. Connection & Live Battery Monitoring
- **Real-time Bluetooth Connection**: Queries paired and active devices via Android's native Bluetooth stack.
- **Tri-Battery Indicator**: Live percentage for Left Earbud, Right Earbud, and Charging Case.
- **Estimated Playtime Engine**: Dynamic remaining hours calculation based on current battery charge.
- **Swift Charge Indicator**: Highlights fast charge capability.

### 2. ANC vs. AI-ENC Noise Control Center
- **Hardware Clarity**: Educates user on the difference between ANC and AI-ENC.
- **AI-ENC Call Enhancement**: Dual HD mic background suppression toggles, wind noise reduction, and voice frequency focus.
- **Call Clarity Simulator**: Test your voice through the AI-ENC filter.

### 3. 13mm Driver Sound Equalizer
- **Tuned Sound Profiles**:
  - *Mivi Signature Sound*
  - *Super Bass (13mm Dynamic Driver Focus)*
  - *Vocal & Podcast Clarity*
  - *Treble & Acoustic Sharpness*
  - *Gaming & Battle Mode Audio*
  - *Balanced Flat*
- **5-Band Graphic Equalizer**: 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz (-10dB to +10dB).
- **Sub-Bass Booster**: 0–100% dial driving the 13mm dynamic diaphragm.

### 4. Battle Mode (50ms Low-Latency Gaming)
- **One-Tap Gaming Mode**: Engages 50ms low-latency audio transmission for zero audio-video lag in competitive FPS and games.
- **Interactive Audio Latency Tester**: Tap-to-ping test to verify auditory and visual sync.
- **Gesture Reminder**: Triple-tap on Right Earbud for quick in-game toggle.

### 5. Find My DuoPods (Earbud Locator)
- **Directional Sound Chirp**: Emit high-frequency sound on Left Earbud, Right Earbud, or Both to locate misplaced buds.
- **Pulsing Radar Sonar Visualizer**: Visual indicator while locator chirps are playing.
- **Last Connected Timestamp & Signal Strength**: Records Bluetooth connection metadata.

### 6. Adaptive Touch Control Directory & Sandbox
- **Gesture Reference**:
  - `1x Tap` (L/R): Play / Pause • Answer / End Call
  - `2x Taps` (Left): Previous Track
  - `2x Taps` (Right): Next Track
  - `3x Taps` (Left): Voice Assistant (Google Assistant / Siri)
  - `3x Taps` (Right): Battle Mode (50ms) Toggle
  - `Long Press 2s` (L/R): Reject Call / Power On-Off
- **Interactive Touch Sandbox**: Practice tapping speed to master single, double, and triple taps.

---

## 🚀 Running the Project

```bash
# Get dependencies
flutter pub get

# Run on connected Android phone or emulator
flutter run

# Build APK
flutter build apk --release
```

---

## 🛠️ Tech Stack & Architecture
- **Framework**: Flutter (Dart 3.14+, Material 3)
- **Platform Layer**: Android Kotlin MethodChannel (`com.mivi.twsmanager/bluetooth`)
  - `BluetoothAdapter` & `BluetoothDevice.getBatteryLevel()`
  - Low-level `AudioTrack` tone generator for earbud localization
  - Android `Equalizer` & `BassBoost` audio effects
- **State Management**: Reactive `ChangeNotifier` / `AnimatedBuilder` architecture
