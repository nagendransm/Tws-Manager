import 'package:flutter/material.dart';
import '../services/tws_service.dart';

class BattleModeScreen extends StatefulWidget {
  final TwsService service;

  const BattleModeScreen({super.key, required this.service});

  @override
  State<BattleModeScreen> createState() => _BattleModeScreenState();
}

class _BattleModeScreenState extends State<BattleModeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dev = widget.service.device;
    final isBattle = dev.isBattleMode;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: const Text(
          "Battle Mode (Low Latency)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // Glowing Gaming Emblem
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final glow = isBattle ? _animController.value * 20 + 8 : 0.0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isBattle
                          ? [const Color(0xFF380816), const Color(0xFF161922)]
                          : [const Color(0xFF1E222D), const Color(0xFF12141C)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isBattle
                          ? const Color(0xFFFF0055).withValues(alpha: 0.6)
                          : Colors.white12,
                      width: isBattle ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isBattle)
                        BoxShadow(
                          color: const Color(0xFFFF0055).withValues(alpha: 0.35),
                          blurRadius: glow,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.sports_esports_rounded,
                        color: isBattle ? const Color(0xFFFF0055) : Colors.white38,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isBattle ? "BATTLE MODE ENGAGED" : "STANDARD AUDIO MODE",
                        style: TextStyle(
                          color: isBattle ? const Color(0xFFFF0055) : Colors.white60,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isBattle ? "Ultra-Low 50ms Real-Time Latency" : "Normal 180ms Latency (Music & Media)",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 18),
                      // Battle Mode Toggle Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBattle ? const Color(0xFFFF0055) : const Color(0xFF232838),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: Icon(isBattle ? Icons.flash_on_rounded : Icons.flash_off_rounded),
                        label: Text(
                          isBattle ? "Disable Battle Mode" : "Activate 50ms Battle Mode",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() {
                            widget.service.toggleBattleMode();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Hardware Shortcut Guide
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: Color(0xFF00BBF9), size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hardware Earbud Shortcut",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Triple-Tap on the Right Earbud at any time during gameplay to instantly toggle Battle Mode without opening the app.",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Audio Latency Benchmark Tester
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
                    "Audio-Visual Sync Tester",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap the pulse pad to test audio response speed through your Mivi DuoPods K2.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _tapCount++;
                        });
                        widget.service.startFinderBeep("BOTH");
                        Future.delayed(const Duration(milliseconds: 150), () {
                          widget.service.stopFinderBeep();
                        });
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isBattle
                              ? const Color(0xFFFF0055).withValues(alpha: 0.15)
                              : const Color(0xFF00BBF9).withValues(alpha: 0.15),
                          border: Border.all(
                            color: isBattle ? const Color(0xFFFF0055) : const Color(0xFF00BBF9),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: isBattle ? const Color(0xFFFF0055) : const Color(0xFF00BBF9),
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBattle ? "50ms" : "180ms",
                              style: TextStyle(
                                color: isBattle ? const Color(0xFFFF0055) : const Color(0xFF00BBF9),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Pings sent: $_tapCount",
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
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
