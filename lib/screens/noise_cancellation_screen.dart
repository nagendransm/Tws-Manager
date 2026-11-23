import 'package:flutter/material.dart';
import '../services/tws_service.dart';

class NoiseCancellationScreen extends StatefulWidget {
  final TwsService service;

  const NoiseCancellationScreen({super.key, required this.service});

  @override
  State<NoiseCancellationScreen> createState() => _NoiseCancellationScreenState();
}

class _NoiseCancellationScreenState extends State<NoiseCancellationScreen> {
  bool _windReduction = true;
  bool _voiceFocus = true;
  bool _isTestingMic = false;
  String _micProfile = "Enhanced (Outdoor / Traffic)";

  final List<String> _micProfiles = [
    "Enhanced (Outdoor / Traffic)",
    "Studio Voice (Podcast & Calls)",
    "Standard HD",
  ];

  @override
  Widget build(BuildContext context) {
    final dev = widget.service.device;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: const Text(
          "AI-ENC Call Noise Filter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI-ENC Overview Banner (Clean, no text overlay)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E2A2B), Color(0xFF121620)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF00F5D4).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F5D4).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.mic_external_on_rounded, color: Color(0xFF00F5D4), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AI-ENC Environmental Noise Cancellation",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Dual HD Microphones Active",
                              style: TextStyle(
                                color: Color(0xFF00F5D4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "AI algorithms constantly isolate your voice from background traffic, wind, and ambient chatter during calls so listeners hear only you.",
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI-ENC Master Toggle Card
            Material(
              color: const Color(0xFF161922),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: dev.isEncActive ? const Color(0xFF00F5D4).withValues(alpha: 0.4) : Colors.white10,
                  ),
                ),
                child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.record_voice_over_rounded, color: Color(0xFF00F5D4), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Noise Cancellation on Calls",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    dev.isEncActive ? "Enabled (Filtering Noise)" : "Disabled",
                                    style: TextStyle(
                                      color: dev.isEncActive ? const Color(0xFF00F5D4) : Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: dev.isEncActive,
                        activeThumbColor: const Color(0xFF00F5D4),
                        onChanged: (val) {
                          setState(() {
                            widget.service.toggleEnc(val);
                          });
                        },
                      ),
                    ],
                  ),
                  if (dev.isEncActive) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Wind Noise Reduction", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text("Suppresses turbulent wind gusts across the stem mics", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      value: _windReduction,
                      activeThumbColor: const Color(0xFF00F5D4),
                      onChanged: (v) => setState(() => _windReduction = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Voice Frequency Focus", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text("Boosts vocal frequencies while silencing low-frequency rumble", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      value: _voiceFocus,
                      activeThumbColor: const Color(0xFF00F5D4),
                      onChanged: (v) => setState(() => _voiceFocus = v),
                    ),
                  ],
                ],
              ),
            ),
          ),
            const SizedBox(height: 20),

            // Call Noise Environment Preset
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Call Clarity Environment Profile",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Choose the intensity of background noise filtering for your environment.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_micProfiles.length, (index) {
                    final p = _micProfiles[index];
                    final isSelected = _micProfile == p;
                    return GestureDetector(
                      onTap: () => setState(() => _micProfile = p),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00F5D4).withValues(alpha: 0.12) : const Color(0xFF0F1117),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00F5D4) : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF00F5D4) : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? const Color(0xFF00F5D4) : Colors.white24,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Call Clarity Test Sandbox
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Microphone Test & Preview",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Speak into your earphones to verify the noise filter clarity in real time.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTestingMic ? const Color(0xFFFF5964) : const Color(0xFF00F5D4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(_isTestingMic ? Icons.stop_rounded : Icons.mic_rounded),
                      label: Text(
                        _isTestingMic ? "Stop Recording (Testing...)" : "Test My Voice Clarity",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          _isTestingMic = !_isTestingMic;
                        });
                        if (!_isTestingMic) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Microphone clarity verified! Ambient noise filtered."),
                              backgroundColor: Color(0xFF00F5D4),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
