import 'package:flutter/material.dart';
import '../services/tws_service.dart';

class TouchControlsScreen extends StatefulWidget {
  final TwsService service;

  const TouchControlsScreen({super.key, required this.service});

  @override
  State<TouchControlsScreen> createState() => _TouchControlsScreenState();
}

class _TouchControlsScreenState extends State<TouchControlsScreen> {
  String _lastDetectedAction = "Tap the sensor below to test gestures";
  int _consecutiveTaps = 0;
  DateTime _lastTapTime = DateTime.now();

  void _handlePadTap() {
    final now = DateTime.now();
    if (now.difference(_lastTapTime).inMilliseconds < 450) {
      _consecutiveTaps++;
    } else {
      _consecutiveTaps = 1;
    }
    _lastTapTime = now;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (DateTime.now().difference(_lastTapTime).inMilliseconds >= 450) {
        setState(() {
          if (_consecutiveTaps == 1) {
            _lastDetectedAction = "1x Tap: Play / Pause Music or Answer / End Call";
          } else if (_consecutiveTaps == 2) {
            _lastDetectedAction = "2x Taps: Skip Track (Right = Next, Left = Prev)";
          } else if (_consecutiveTaps >= 3) {
            _lastDetectedAction = "3x Taps: Battle Mode (Right) / Voice Assistant (Left)";
          }
          _consecutiveTaps = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: const Text(
          "Adaptive Touch Controls",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gesture Reference Table
            const Text(
              "Gesture Directory",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildGestureCard(
              gesture: "1x Single Tap",
              leftAction: "Play / Pause • Answer / End Call",
              rightAction: "Play / Pause • Answer / End Call",
              icon: Icons.touch_app_rounded,
              color: const Color(0xFF00BBF9),
            ),
            const SizedBox(height: 10),
            _buildGestureCard(
              gesture: "2x Double Tap",
              leftAction: "⏮ Previous Track",
              rightAction: "⏭ Next Track",
              icon: Icons.double_arrow_rounded,
              color: const Color(0xFF00F5D4),
            ),
            const SizedBox(height: 10),
            _buildGestureCard(
              gesture: "3x Triple Tap",
              leftAction: "🎙️ Google Assistant / Siri",
              rightAction: "⚡ Battle Mode (50ms)",
              icon: Icons.flash_on_rounded,
              color: const Color(0xFFFF0055),
            ),
            const SizedBox(height: 10),
            _buildGestureCard(
              gesture: "Long Press (2s)",
              leftAction: "Reject Call / Power Toggle",
              rightAction: "Reject Call / Power Toggle",
              icon: Icons.timer_rounded,
              color: const Color(0xFFFEE440),
            ),
            const SizedBox(height: 24),

            // Interactive Touch Sensor Simulator
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text(
                    "Touch Sensor Sandbox",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap repeatedly inside the circle to practice your tap timing.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _handlePadTap,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF00BBF9), Color(0xFF0F172A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BBF9).withValues(alpha: 0.3),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.fingerprint_rounded, color: Colors.white, size: 54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0D13),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      _lastDetectedAction,
                      style: const TextStyle(
                        color: Color(0xFF00F5D4),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildGestureCard({
    required String gesture,
    required String leftAction,
    required String rightAction,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gesture,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text("Left: ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(leftAction, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text("Right: ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(rightAction, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
