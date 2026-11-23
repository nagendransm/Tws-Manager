import 'package:flutter/material.dart';
import '../services/tws_service.dart';

class EqualizerScreen extends StatefulWidget {
  final TwsService service;

  const EqualizerScreen({super.key, required this.service});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  final List<String> _presets = [
    "Mivi Signature",
    "Super Bass (13mm)",
    "Vocal Clarity",
    "Treble Sharp",
    "Gaming / Battle",
    "Balanced",
  ];

  final List<String> _freqLabels = ["60Hz", "230Hz", "910Hz", "3.6kHz", "14kHz"];

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        title: const Text(
          "13mm Driver Equalizer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Tuning Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C2411), Color(0xFF161922)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFEE440).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.speaker_rounded, color: Color(0xFFFEE440), size: 32),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "13mm Electroplated Dynamic Drivers",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Hardware acoustic chamber tuned for deep low-end punch and crystalline highs.",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sound Presets Carousel
            const Text(
              "Tuned Sound Profiles",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final preset = _presets[i];
                  final isSelected = s.activePreset == preset;
                  return ChoiceChip(
                    label: Text(preset),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFEE440),
                    backgroundColor: const Color(0xFF161922),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFFEE440) : Colors.white10,
                    ),
                    onSelected: (_) {
                      setState(() {
                        s.setEqPreset(preset);
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 5-Band Graphic Equalizer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "5-Band Manual Equalizer",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            s.setEqPreset("Balanced");
                          });
                        },
                        child: const Text("Reset Flat", style: TextStyle(color: Color(0xFF00BBF9), fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sliders Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(s.eqBands.length, (index) {
                      final val = s.eqBands[index];
                      return Column(
                        children: [
                          Text(
                            "${val > 0 ? '+' : ''}${val.toInt()}dB",
                            style: const TextStyle(color: Color(0xFFFEE440), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 160,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                  activeTrackColor: const Color(0xFFFEE440),
                                  inactiveTrackColor: Colors.white12,
                                  thumbColor: const Color(0xFFFEE440),
                                ),
                                child: Slider(
                                  min: -10.0,
                                  max: 10.0,
                                  value: val,
                                  onChanged: (newVal) {
                                    setState(() {
                                      s.updateEqBand(index, newVal);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _freqLabels[index],
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bass Boost (13mm Subwoofer Enhancement)
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.surround_sound_rounded, color: Color(0xFF00F5D4), size: 22),
                          SizedBox(width: 10),
                          Text(
                            "Sub-Bass Booster",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        "${s.bassBoost}%",
                        style: const TextStyle(color: Color(0xFF00F5D4), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Drives the 13mm diaphragm to deliver thunderous sub-bass resonance.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF00F5D4),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF00F5D4),
                      trackHeight: 5,
                    ),
                    child: Slider(
                      min: 0,
                      max: 100,
                      value: s.bassBoost.toDouble(),
                      onChanged: (v) {
                        setState(() {
                          s.updateBassBoost(v.toInt());
                        });
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
