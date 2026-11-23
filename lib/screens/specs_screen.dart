import 'package:flutter/material.dart';

class SpecsScreen extends StatelessWidget {
  const SpecsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: const Text(
          "Mivi DuoPods K2 Specifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Badge
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2838), Color(0xFF10131B)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF00BBF9).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF00F5D4), size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mivi DuoPods K2",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Engineered & Made in India • Premium Budget True Wireless Stereo",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Specifications Grid/List
            _buildSpecGroup("Acoustic & Audio", [
              _buildSpecRow("Sound Driver", "13mm Electroplated Dynamic Drivers"),
              _buildSpecRow("Audio Tuning", "Deep Bass, Balanced Midrange, Crisp Highs"),
              _buildSpecRow("Bluetooth Version", "v5.3 (High Efficiency, 10m Range)"),
              _buildSpecRow("Audio Codecs", "AAC, SBC"),
            ]),
            const SizedBox(height: 16),

            _buildSpecGroup("Noise Control & Microphones", [
              _buildSpecRow("Environmental Noise (ENC)", "AI-ENC Powered by Dual HD Mics"),
              _buildSpecRow("Microphone Config", "Dual HD Mics with AI background suppression"),
            ]),
            const SizedBox(height: 16),

            _buildSpecGroup("Battery & Charging", [
              _buildSpecRow("Total Playtime", "Up to 40 Hours (Earbuds + Case)"),
              _buildSpecRow("Earbud Playtime", "~8 Hours continuous playback per charge"),
              _buildSpecRow("Swift / Fast Charging", "10 min charge = 500 mins (~8.3h) playtime"),
              _buildSpecRow("Charging Port", "USB Type-C"),
            ]),
            const SizedBox(height: 16),

            _buildSpecGroup("Gaming & Durability", [
              _buildSpecRow("Gaming Latency", "50ms Battle Mode (Triple-tap activation)"),
              _buildSpecRow("Water Resistance", "IPX4 Sweat & Splash Resistant"),
              _buildSpecRow("Dual Device Pairing", "Yes (Multipoint connectivity support)"),
              _buildSpecRow("Voice Assistant", "Google Assistant & Siri Compatible"),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecGroup(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00BBF9),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildSpecRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(key, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
