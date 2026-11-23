import 'package:flutter/material.dart';
import '../models/tws_device.dart';

class BatteryCard extends StatelessWidget {
  final TwsDevice device;

  const BatteryCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFFFEE440), size: 20),
                  SizedBox(width: 6),
                  Text(
                    "Battery & Playtime",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              // Swift Charge Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEE440), Color(0xFFFF9E00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "⚡ Swift Charge: 10m = 500m",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Three Columns: Left Earbud, Case, Right Earbud
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                label: "Left Bud",
                value: device.isConnected && device.leftBattery > 0 ? "${device.leftBattery}%" : "--",
                icon: Icons.headphones_rounded,
                progress: device.isConnected && device.leftBattery > 0 ? device.leftBattery / 100.0 : 0.0,
                color: const Color(0xFF00F5D4),
              ),
              _buildMetric(
                label: "Charging Case",
                value: device.isConnected && device.caseBattery > 0 ? "${device.caseBattery}%" : "--",
                icon: Icons.cases_rounded,
                progress: device.isConnected && device.caseBattery > 0 ? device.caseBattery / 100.0 : 0.0,
                color: const Color(0xFF00BBF9),
              ),
              _buildMetric(
                label: "Right Bud",
                value: device.isConnected && device.rightBattery > 0 ? "${device.rightBattery}%" : "--",
                icon: Icons.headphones_rounded,
                progress: device.isConnected && device.rightBattery > 0 ? device.rightBattery / 100.0 : 0.0,
                color: const Color(0xFF00F5D4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          // Estimated Playtime
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Earbuds Playtime",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "~${device.estimatedEarbudHours.toStringAsFixed(1)} Hours",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Total with Case (40h Max)",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "~${device.estimatedTotalHours.toStringAsFixed(1)} Hours",
                    style: const TextStyle(
                      color: Color(0xFF00F5D4),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required IconData icon,
    required double progress,
    required Color color,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 4.5,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
