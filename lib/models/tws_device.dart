class TwsDevice {
  final String name;
  final String address;
  final bool isConnected;
  final int leftBattery; // -1 if disconnected or unknown
  final int rightBattery; // -1 if disconnected or unknown
  final int caseBattery;
  final bool isBattleMode;
  final bool isEncActive;
  final String bluetoothVersion;
  final String driverSize;
  final String audioCodec;
  final int signalStrengthRssi;
  final DateTime lastConnected;

  const TwsDevice({
    required this.name,
    required this.address,
    required this.isConnected,
    this.leftBattery = -1,
    this.rightBattery = -1,
    this.caseBattery = -1,
    this.isBattleMode = false,
    this.isEncActive = true,
    this.bluetoothVersion = "Bluetooth 5.3",
    this.driverSize = "Dynamic Audio Driver",
    this.audioCodec = "AAC / SBC",
    this.signalStrengthRssi = -55,
    required this.lastConnected,
  });

  TwsDevice copyWith({
    String? name,
    String? address,
    bool? isConnected,
    int? leftBattery,
    int? rightBattery,
    int? caseBattery,
    bool? isBattleMode,
    bool? isEncActive,
    String? bluetoothVersion,
    String? driverSize,
    String? audioCodec,
    int? signalStrengthRssi,
    DateTime? lastConnected,
  }) {
    return TwsDevice(
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      leftBattery: leftBattery ?? this.leftBattery,
      rightBattery: rightBattery ?? this.rightBattery,
      caseBattery: caseBattery ?? this.caseBattery,
      isBattleMode: isBattleMode ?? this.isBattleMode,
      isEncActive: isEncActive ?? this.isEncActive,
      bluetoothVersion: bluetoothVersion ?? this.bluetoothVersion,
      driverSize: driverSize ?? this.driverSize,
      audioCodec: audioCodec ?? this.audioCodec,
      signalStrengthRssi: signalStrengthRssi ?? this.signalStrengthRssi,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  // Calculate estimated listening hours
  double get estimatedEarbudHours {
    if (!isConnected || leftBattery <= 0) return 0.0;
    return (leftBattery.clamp(0, 100) / 100.0) * 8.0;
  }

  double get estimatedTotalHours {
    if (!isConnected) return 0.0;
    final earbudHours = estimatedEarbudHours;
    final caseHours = caseBattery > 0 ? (caseBattery.clamp(0, 100) / 100.0) * 32.0 : 0.0;
    return earbudHours + caseHours;
  }
}
