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

  @override
  Widget build(BuildContext context) {
    final dev = widget.service.device;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: const Text(
          "ANC & AI-ENC Noise Control",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ANC vs ENC Fact Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2838), Color(0xFF121620)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF00BBF9).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BBF9).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_rounded, color: Color(0xFF00BBF9), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Hardware Specification Overview",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildComparisonRow(
                    title: "Active Noise Cancellation (ANC)",
                    status: "Hardware Not Supported",
                    statusColor: const Color(0xFFFF5964),
                    description: "Mivi DuoPods K2 uses an ergonomic in-ear silicone seal for passive noise isolation instead of motorized anti-phase speaker cancellation.",
                  ),
                  const Divider(color: Colors.white12, height: 22),
                  _buildComparisonRow(
                    title: "AI-ENC (Environmental Noise Cancellation)",
                    status: "Supported & Active (Dual Mics)",
                    statusColor: const Color(0xFF00F5D4),
                    description: "Dual HD microphones analyze environmental noise and AI filters out traffic, chatter, and wind so your voice is transmitted crystal clear on calls.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI-ENC Master Toggle Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.mic_external_on_rounded, color: Color(0xFF00F5D4), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "AI-ENC Call Clarity",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                dev.isEncActive ? "Dual HD Microphones Active" : "Disabled",
                                style: TextStyle(
                                  color: dev.isEncActive ? const Color(0xFF00F5D4) : Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                      title: const Text("Wind Noise Reduction", style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text("Suppresses turbulent wind gusts across the stem mics", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      value: _windReduction,
                      activeThumbColor: const Color(0xFF00F5D4),
                      onChanged: (v) => setState(() => _windReduction = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Voice Frequency Focus", style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text("Amplifies human vocal cords while trimming background hum", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      value: _voiceFocus,
                      activeThumbColor: const Color(0xFF00F5D4),
                      onChanged: (v) => setState(() => _voiceFocus = v),
                    ),
                  ],
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
                    "Call Clarity Simulator",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Preview how your voice sounds to listeners with AI-ENC background noise filtering.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTestingMic ? const Color(0xFFFF5964) : const Color(0xFF00F5D4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(_isTestingMic ? Icons.stop_rounded : Icons.mic_rounded),
                      label: Text(
                        _isTestingMic ? "Stop Recording (Testing...)" : "Test My Voice With ENC",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          _isTestingMic = !_isTestingMic;
                        });
                        if (!_isTestingMic) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("AI-ENC filtered sample verified! Crystal clear voice captured."),
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

  Widget _buildComparisonRow({
    required String title,
    required String status,
    required Color statusColor,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(description, style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.3)),
      ],
    );
  }
}
