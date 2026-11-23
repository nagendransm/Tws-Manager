import 'package:flutter/material.dart';

class EarbudVisual extends StatelessWidget {
  final bool isLeft;
  final int batteryLevel;
  final bool isConnected;
  final bool isBeeping;
  final VoidCallback? onTap;

  const EarbudVisual({
    super.key,
    required this.isLeft,
    required this.batteryLevel,
    required this.isConnected,
    this.isBeeping = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sideLabel = isLeft ? "L" : "R";
    final sideName = isLeft ? "Left Earbud" : "Right Earbud";
    final batteryColor = !isConnected || batteryLevel <= 0
        ? Colors.white38
        : batteryLevel > 50
            ? const Color(0xFF00F5D4)
            : batteryLevel > 20
                ? const Color(0xFFFEE440)
                : const Color(0xFFFF5964);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Earbud Body with Glow
          Container(
            width: 82,
            height: 104,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isLeft ? Alignment.topLeft : Alignment.topRight,
                end: isLeft ? Alignment.bottomRight : Alignment.bottomLeft,
                colors: [
                  const Color(0xFF282D3C),
                  const Color(0xFF13161F),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isBeeping
                    ? const Color(0xFFFF0055)
                    : isConnected
                        ? const Color(0xFF00BBF9).withValues(alpha: 0.5)
                        : Colors.white12,
                width: isBeeping ? 2.5 : 1.5,
              ),
              boxShadow: [
                if (isBeeping)
                  BoxShadow(
                    color: const Color(0xFFFF0055).withValues(alpha: 0.6),
                    blurRadius: 18,
                    spreadRadius: 4,
                  )
                else if (isConnected)
                  BoxShadow(
                    color: const Color(0xFF00BBF9).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Metallic Trim Accent
                Positioned(
                  top: 14,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF4A5568), Color(0xFF1A202C)],
                      ),
                      border: Border.all(color: const Color(0xFF00BBF9), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        sideLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                // Stem / Mic Indicator (AI-ENC Dual Mic)
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 14,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0D13),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected ? const Color(0xFF00F5D4) : Colors.grey,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            sideName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Battery Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: batteryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: batteryColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  batteryLevel > 80
                      ? Icons.battery_full_rounded
                      : batteryLevel > 30
                          ? Icons.battery_5_bar_rounded
                          : Icons.battery_alert_rounded,
                  size: 13,
                  color: batteryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isConnected && batteryLevel > 0 ? "$batteryLevel%" : "--",
                  style: TextStyle(
                    color: batteryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
