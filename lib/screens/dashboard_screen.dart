import 'package:flutter/material.dart';
import '../services/tws_service.dart';
import '../widgets/earbud_visual.dart';
import 'equalizer_screen.dart';
import 'noise_cancellation_screen.dart';
import 'find_earbuds_screen.dart';
import 'touch_controls_screen.dart';
import 'specs_screen.dart';

class DashboardScreen extends StatefulWidget {
  final TwsService service;

  const DashboardScreen({super.key, required this.service});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.headphones_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.device.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    service.device.isConnected ? "Auto-Connected • BT 5.3" : "Waiting for connection...",
                    style: TextStyle(
                      color: service.device.isConnected ? const Color(0xFF00F5D4) : Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Auto-Scan Status",
            icon: service.isScanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BBF9)),
                  )
                : const Icon(Icons.sync_rounded, color: Colors.white70, size: 20),
            onPressed: () => service.refreshConnection(),
          ),
          IconButton(
            tooltip: "Hardware Specifications",
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpecsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          // Screen 1: Dashboard Home (FITS ON 1ST SCREEN WITHOUT ANY SCROLLING)
          _buildCompactHomeView(context, service),
          // Screen 2: 13mm Driver Equalizer
          EqualizerScreen(service: service),
          // Screen 3: AI-ENC Noise Filter
          NoiseCancellationScreen(service: service),
          // Screen 4: Touch Controls
          TouchControlsScreen(service: service),
        ],
      ),
      // Material Design 3 Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        backgroundColor: const Color(0xFF161922),
        indicatorColor: const Color(0xFF00BBF9).withValues(alpha: 0.25),
        elevation: 2,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF00BBF9)),
            label: "Device",
          ),
          NavigationDestination(
            icon: Icon(Icons.equalizer_outlined),
            selectedIcon: Icon(Icons.equalizer_rounded, color: Color(0xFF00BBF9)),
            label: "Sound EQ",
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none_rounded),
            selectedIcon: Icon(Icons.mic_rounded, color: Color(0xFF00F5D4)),
            label: "AI-ENC",
          ),
          NavigationDestination(
            icon: Icon(Icons.touch_app_outlined),
            selectedIcon: Icon(Icons.touch_app_rounded, color: Color(0xFF00BBF9)),
            label: "Touch",
          ),
        ],
      ),
    );
  }

  // SCREEN 1 (FITS 100% IN VIEWPORT - ZERO SCROLLING)
  Widget _buildCompactHomeView(BuildContext context, TwsService service) {
    final dev = service.device;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. Hero Earbuds & Case Material 3 Card
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: const Color(0xFF161922),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        EarbudVisual(
                          isLeft: true,
                          batteryLevel: dev.leftBattery,
                          isConnected: dev.isConnected,
                          isBeeping: service.isPlayingFinderTone &&
                              (service.activeFinderSide == "LEFT" || service.activeFinderSide == "BOTH"),
                          onTap: () => setState(() => _currentNavIndex = 3),
                        ),
                        // Compact Case Visual Indicator
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF202636),
                                border: Border.all(
                                  color: const Color(0xFF00BBF9).withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.cases_rounded, color: Colors.white, size: 24),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Case (40h)",
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                            Text(
                              dev.isConnected && dev.caseBattery > 0 ? "${dev.caseBattery}%" : "--",
                              style: const TextStyle(
                                color: Color(0xFF00BBF9),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        EarbudVisual(
                          isLeft: false,
                          batteryLevel: dev.rightBattery,
                          isConnected: dev.isConnected,
                          isBeeping: service.isPlayingFinderTone &&
                              (service.activeFinderSide == "RIGHT" || service.activeFinderSide == "BOTH"),
                          onTap: () => setState(() => _currentNavIndex = 3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Auto-Connected Pill & Proximity
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: dev.isConnected
                            ? const Color(0xFF00F5D4).withValues(alpha: 0.12)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dev.isConnected
                              ? const Color(0xFF00F5D4).withValues(alpha: 0.3)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            dev.isConnected ? Icons.check_circle_rounded : Icons.bluetooth_searching_rounded,
                            size: 13,
                            color: dev.isConnected ? const Color(0xFF00F5D4) : Colors.white60,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dev.isConnected ? "Auto-Connected & Synced" : "Searching for Earbuds...",
                            style: TextStyle(
                              color: dev.isConnected ? const Color(0xFF00F5D4) : Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Playtime & Fast Charge M3 Card
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: const Color(0xFF161922),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: Color(0xFFFEE440), size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Battery & Playtime",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE440).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFEE440).withValues(alpha: 0.35)),
                          ),
                          child: const Text(
                            "⚡ 10m = 500m Playtime",
                            style: TextStyle(color: Color(0xFFFEE440), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Buds Remaining", style: TextStyle(color: Colors.white54, fontSize: 11)),
                            Text(
                              dev.isConnected && dev.leftBattery > 0
                                  ? "~${dev.estimatedEarbudHours.toStringAsFixed(1)} Hours"
                                  : "-- Hours",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Total With Case (40h Max)", style: TextStyle(color: Colors.white54, fontSize: 11)),
                            Text(
                              dev.isConnected && dev.caseBattery > 0
                                  ? "~${dev.estimatedTotalHours.toStringAsFixed(1)} Hours"
                                  : "-- Hours",
                              style: const TextStyle(color: Color(0xFF00F5D4), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Quick Action Material 3 Toggles
            Row(
              children: [
                // Battle Mode Toggle Card
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: dev.isBattleMode
                        ? const Color(0xFF2C0A15)
                        : const Color(0xFF161922),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: dev.isBattleMode ? const Color(0xFFFF0055) : Colors.white10,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => service.toggleBattleMode(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.sports_esports_rounded,
                                  color: dev.isBattleMode ? const Color(0xFFFF0055) : Colors.white54,
                                  size: 22,
                                ),
                                Switch(
                                  value: dev.isBattleMode,
                                  activeThumbColor: const Color(0xFFFF0055),
                                  onChanged: (_) => service.toggleBattleMode(),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Battle Mode",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              dev.isBattleMode ? "50ms Low Latency" : "Normal Audio",
                              style: TextStyle(
                                color: dev.isBattleMode ? const Color(0xFFFF0055) : Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // AI-ENC Noise Filter Toggle Card
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: dev.isEncActive
                        ? const Color(0xFF0C2424)
                        : const Color(0xFF161922),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: dev.isEncActive ? const Color(0xFF00F5D4) : Colors.white10,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => service.toggleEnc(!dev.isEncActive),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.record_voice_over_rounded,
                                  color: dev.isEncActive ? const Color(0xFF00F5D4) : Colors.white54,
                                  size: 22,
                                ),
                                Switch(
                                  value: dev.isEncActive,
                                  activeThumbColor: const Color(0xFF00F5D4),
                                  onChanged: (v) => service.toggleEnc(v),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "AI-ENC Noise Filter",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              dev.isEncActive ? "Dual HD Mic Active" : "Disabled",
                              style: TextStyle(
                                color: dev.isEncActive ? const Color(0xFF00F5D4) : Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 4. Quick Action Button Bar (Find Earbuds & Sound EQ)
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2234),
                      foregroundColor: const Color(0xFF00BBF9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.radar_rounded, size: 18),
                    label: const Text("Find Earbuds", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FindEarbudsScreen(service: service)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF262414),
                      foregroundColor: const Color(0xFFFEE440),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.equalizer_rounded, size: 18),
                    label: Text(service.activePreset, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => setState(() => _currentNavIndex = 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
