import 'package:flutter/material.dart';
import '../services/tws_service.dart';
import '../widgets/earbud_visual.dart';
import '../widgets/battery_card.dart';
import 'equalizer_screen.dart';
import 'noise_cancellation_screen.dart';
import 'battle_mode_screen.dart';
import 'find_earbuds_screen.dart';
import 'touch_controls_screen.dart';
import 'specs_screen.dart';

class DashboardScreen extends StatelessWidget {
  final TwsService service;

  const DashboardScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final dev = service.device;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF00BBF9).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.headset_rounded, color: Color(0xFF00BBF9), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dev.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dev.isConnected ? "Connected • AAC 5.3" : "Disconnected",
                  style: TextStyle(
                    color: dev.isConnected ? const Color(0xFF00F5D4) : Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Refresh Bluetooth",
            icon: service.isScanning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BBF9)),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => service.refreshConnection(),
          ),
          IconButton(
            tooltip: "Hardware Specifications",
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpecsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // Visual Earbuds Display Area
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [
                    Color(0xFF1E2433),
                    Color(0xFF10131B),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TouchControlsScreen(service: service)),
                          );
                        },
                      ),
                      // Charging Case Visual Icon
                      Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2C344A), Color(0xFF161922)],
                              ),
                              border: Border.all(color: const Color(0xFF00BBF9).withValues(alpha: 0.4)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00BBF9).withValues(alpha: 0.2),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.cases_rounded, color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Case (40h)",
                            style: TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                          Text(
                            "${dev.caseBattery}%",
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TouchControlsScreen(service: service)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Connection Quick Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: dev.isConnected ? const Color(0xFFFF5964) : const Color(0xFF00F5D4),
                          side: BorderSide(
                            color: dev.isConnected ? const Color(0xFFFF5964).withValues(alpha: 0.4) : const Color(0xFF00F5D4).withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: Icon(dev.isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_disabled_rounded, size: 16),
                        label: Text(dev.isConnected ? "Disconnect" : "Connect TWS"),
                        onPressed: () => service.toggleConnection(),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BBF9).withValues(alpha: 0.2),
                          foregroundColor: const Color(0xFF00BBF9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(Icons.radar_rounded, size: 16),
                        label: const Text("Find Earbuds"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FindEarbudsScreen(service: service)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Battery & Playtime Card
            BatteryCard(device: dev),
            const SizedBox(height: 16),

            // Feature Quick Tiles Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                // Battle Mode Tile
                _buildActionTile(
                  context,
                  title: "Battle Mode",
                  subtitle: dev.isBattleMode ? "50ms Active" : "Off (Tap to Enable)",
                  icon: Icons.sports_esports_rounded,
                  accentColor: const Color(0xFFFF0055),
                  isActive: dev.isBattleMode,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BattleModeScreen(service: service)),
                    );
                  },
                ),
                // AI-ENC Noise Cancellation Tile
                _buildActionTile(
                  context,
                  title: "AI-ENC Audio",
                  subtitle: dev.isEncActive ? "Dual HD Mic Active" : "Disabled",
                  icon: Icons.record_voice_over_rounded,
                  accentColor: const Color(0xFF00F5D4),
                  isActive: dev.isEncActive,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NoiseCancellationScreen(service: service)),
                    );
                  },
                ),
                // Equalizer Tile (13mm Driver Tuning)
                _buildActionTile(
                  context,
                  title: "13mm Sound EQ",
                  subtitle: service.activePreset,
                  icon: Icons.equalizer_rounded,
                  accentColor: const Color(0xFFFEE440),
                  isActive: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EqualizerScreen(service: service)),
                    );
                  },
                ),
                // Touch Controls Tile
                _buildActionTile(
                  context,
                  title: "Touch Controls",
                  subtitle: "Tap, Double, Triple",
                  icon: Icons.touch_app_rounded,
                  accentColor: const Color(0xFF00BBF9),
                  isActive: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TouchControlsScreen(service: service)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161922),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? accentColor.withValues(alpha: 0.35) : Colors.white10,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: accentColor.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isActive ? accentColor : Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
