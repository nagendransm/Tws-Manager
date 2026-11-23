import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/tws_device.dart';

class TwsService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('com.mivi.twsmanager/bluetooth');

  TwsDevice _device = TwsDevice(
    name: "Mivi DuoPods K2",
    address: "Connected (Bluetooth 5.3)",
    isConnected: true,
    leftBattery: 85,
    rightBattery: 85,
    caseBattery: 90,
    isBattleMode: false,
    isEncActive: true,
    lastConnected: DateTime.now(),
  );

  bool _isScanning = false;
  bool _isPlayingFinderTone = false;
  String _activeFinderSide = "NONE";
  List<Map<String, dynamic>> _pairedDevices = [];

  // Equalizer 5-Band settings (-10dB to +10dB)
  List<double> _eqBands = [4.0, 2.0, 0.0, 3.0, 5.0]; // 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz
  int _bassBoost = 65; // 0 to 100%
  String _activePreset = "Mivi Signature";

  TwsDevice get device => _device;
  bool get isScanning => _isScanning;
  bool get isPlayingFinderTone => _isPlayingFinderTone;
  String get activeFinderSide => _activeFinderSide;
  List<Map<String, dynamic>> get pairedDevices => _pairedDevices;
  List<double> get eqBands => _eqBands;
  int get bassBoost => _bassBoost;
  String get activePreset => _activePreset;

  TwsService() {
    refreshConnection();
  }

  Future<void> refreshConnection() async {
    _isScanning = true;
    notifyListeners();

    try {
      final info = await _channel.invokeMethod<Map>('getConnectedTwsInfo');
      if (info != null) {
        final battery = (info['batteryLevel'] as num?)?.toInt() ?? 85;
        final connected = (info['isConnected'] as bool?) ?? true;
        final name = (info['name'] as String?) ?? "Mivi DuoPods K2";
        final address = (info['address'] as String?) ?? "BT-5.3-AAC";

        _device = _device.copyWith(
          name: name.isEmpty ? "Mivi DuoPods K2" : name,
          address: address,
          isConnected: connected,
          leftBattery: battery > 0 ? battery : 85,
          rightBattery: battery > 0 ? battery : 80,
          lastConnected: DateTime.now(),
        );
      }

      final devices = await _channel.invokeListMethod<Map>('getPairedDevices');
      if (devices != null) {
        _pairedDevices = devices.map((d) => Map<String, dynamic>.from(d)).toList();
      }
    } catch (e) {
      debugPrint("Native Bluetooth check: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  void toggleConnection() {
    _device = _device.copyWith(isConnected: !_device.isConnected);
    notifyListeners();
  }

  void toggleBattleMode() {
    _device = _device.copyWith(isBattleMode: !_device.isBattleMode);
    notifyListeners();
  }

  void toggleEnc(bool enabled) {
    _device = _device.copyWith(isEncActive: enabled);
    notifyListeners();
  }

  Future<void> startFinderBeep(String side) async {
    _isPlayingFinderTone = true;
    _activeFinderSide = side;
    notifyListeners();

    try {
      await _channel.invokeMethod('playFinderBeep', {
        'side': side, // 'LEFT', 'RIGHT', 'BOTH'
        'durationMs': 10000,
      });
    } catch (e) {
      debugPrint("Native playFinderBeep: $e");
    }
  }

  Future<void> stopFinderBeep() async {
    _isPlayingFinderTone = false;
    _activeFinderSide = "NONE";
    notifyListeners();

    try {
      await _channel.invokeMethod('stopFinderBeep');
    } catch (e) {
      debugPrint("Native stopFinderBeep: $e");
    }
  }

  void setEqPreset(String presetName) {
    _activePreset = presetName;
    switch (presetName) {
      case "Mivi Signature":
        _eqBands = [5.0, 3.0, 0.0, 2.0, 4.0];
        _bassBoost = 70;
        break;
      case "Super Bass (13mm)":
        _eqBands = [8.0, 6.0, 1.0, 0.0, 2.0];
        _bassBoost = 95;
        break;
      case "Vocal Clarity":
        _eqBands = [-2.0, 1.0, 6.0, 5.0, 2.0];
        _bassBoost = 30;
        break;
      case "Treble Sharp":
        _eqBands = [-1.0, 0.0, 2.0, 6.0, 8.0];
        _bassBoost = 40;
        break;
      case "Gaming / Battle":
        _eqBands = [6.0, 2.0, 4.0, 7.0, 5.0];
        _bassBoost = 60;
        break;
      case "Balanced":
      default:
        _eqBands = [0.0, 0.0, 0.0, 0.0, 0.0];
        _bassBoost = 50;
        break;
    }
    _applyEqNative();
    notifyListeners();
  }

  void updateEqBand(int index, double value) {
    if (index >= 0 && index < _eqBands.length) {
      _eqBands[index] = value;
      _activePreset = "Custom";
      _applyEqNative();
      notifyListeners();
    }
  }

  void updateBassBoost(int value) {
    _bassBoost = value;
    _applyEqNative();
    notifyListeners();
  }

  Future<void> _applyEqNative() async {
    try {
      for (int i = 0; i < _eqBands.length; i++) {
        // Android EQ band levels in millibels (-1000 to +1000)
        final millibels = (_eqBands[i] * 100).toInt();
        await _channel.invokeMethod('setEqualizerBand', {'band': i, 'level': millibels});
      }
      await _channel.invokeMethod('setBassBoost', {'strength': (_bassBoost * 10)});
    } catch (_) {}
  }
}
