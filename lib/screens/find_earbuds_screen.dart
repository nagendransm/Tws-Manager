import 'package:flutter/material.dart';
import '../services/tws_service.dart';

class FindEarbudsScreen extends StatefulWidget {
  final TwsService service;

  const FindEarbudsScreen({super.key, required this.service});

  @override
  State<FindEarbudsScreen> createState() => _FindEarbudsScreenState();
}

class _FindEarbudsScreenState extends State<FindEarbudsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sonarController;

  @override
  void initState() {
    super.initState();
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _sonarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final isBeeping = s.isPlayingFinderTone;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: const Text(
          "Find My DuoPods",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // Safety Hearing Alert
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF33200B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFEE440).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFEE440), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "CAUTION: Remove earbuds from your ears before activating the tone. The alert emits high-frequency sound to help locate misplaced buds.",
                      style: TextStyle(color: Color(0xFFFEE440), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sonar Radar Visualizer
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _sonarController,
                  builder: (context, child) {
                    final progress = _sonarController.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isBeeping)
                          Container(
                            width: 190 * progress,
                            height: 190 * progress,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFF0055).withValues(alpha: 1.0 - progress),
                                width: 2,
                              ),
                            ),
                          ),
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isBeeping
                                ? const Color(0xFFFF0055).withValues(alpha: 0.15)
                                : const Color(0xFF00BBF9).withValues(alpha: 0.12),
                            border: Border.all(
                              color: isBeeping ? const Color(0xFFFF0055) : const Color(0xFF00BBF9),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isBeeping ? Icons.volume_up_rounded : Icons.radar_rounded,
                            color: isBeeping ? const Color(0xFFFF0055) : const Color(0xFF00BBF9),
                            size: 48,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isBeeping ? "EMITTING LOUD FINDER CHIRP (${s.activeFinderSide})" : "Earbuds Standby",
              style: TextStyle(
                color: isBeeping ? const Color(0xFFFF0055) : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 24),

            // Trigger Buttons
            if (isBeeping)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0055),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.stop_circle_rounded),
                label: const Text("STOP ALERT TONE", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  setState(() {
                    s.stopFinderBeep();
                  });
                },
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChirpButton(
                    context,
                    label: "Ring Left",
                    side: "LEFT",
                    icon: Icons.headphones_rounded,
                  ),
                  _buildChirpButton(
                    context,
                    label: "Ring Both",
                    side: "BOTH",
                    icon: Icons.volume_up_rounded,
                  ),
                  _buildChirpButton(
                    context,
                    label: "Ring Right",
                    side: "RIGHT",
                    icon: Icons.headphones_rounded,
                  ),
                ],
              ),
            const SizedBox(height: 28),

            // Last Seen Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Color(0xFF00F5D4), size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Last Connected Status",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Connected at: ${s.device.lastConnected.toLocal().toString().split('.')[0]}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Proximity Signal: -55 dBm (Strong Connection ~1-3m)",
                    style: TextStyle(color: Color(0xFF00F5D4), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChirpButton(
    BuildContext context, {
    required String label,
    required String side,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1C2230),
        foregroundColor: const Color(0xFF00BBF9),
        elevation: 0,
        side: const BorderSide(color: Color(0xFF00BBF9), width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      onPressed: () {
        setState(() {
          widget.service.startFinderBeep(side);
        });
      },
    );
  }
}
