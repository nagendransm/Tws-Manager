import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/tws_device.dart';

class TwsService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('com.mivi.twsmanager/bluetooth');

  TwsDevice _device = TwsDevice(
    name: "Scanning for Earphones...",
    address: "Waiting for connection...",
    isConnected: false,
    leftBattery: -1,
    rightBattery: -1,
    caseBattery: -1,
    isBattleMode: false,
    isEncActive: true,
    lastConnected: DateTime.now(),
  );

  bool _isScanning = false;
  bool _isPlayingFinderTone = false;
  String _activeFinderSide = "NONE";
  List<Map<String, dynamic>> _pairedDevices = [];
  Timer? _autoConnectTimer;

  // Equalizer 5-Band settings (-10dB to +10dB)
  List<double> _eqBands = [4.0, 2.0, 0.0, 3.0, 5.0]; // 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz
  int _bassBoost = 60; // 0 to 100%
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
    _initChannelListener();
    refreshConnection();
    // Auto-detect and auto-connect timer: checks Bluetooth connection every 2 seconds
    _autoConnectTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      refreshConnection(silent: true);
    });
  }

  void _initChannelListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBluetoothStateChanged') {
        if (call.arguments is Map) {
          _updateFromNativeData(Map<String, dynamic>.from(call.arguments as Map));
        }
      }
    });
  }

  void _updateFromNativeData(Map<String, dynamic> info) {
    final connected = (info['isConnected'] as bool?) ?? false;
    final name = (info['name'] as String?) ?? "";
    final address = (info['address'] as String?) ?? "";
    final battery = (info['batteryLevel'] as num?)?.toInt() ?? -1;
    final driver = (info['driverSize'] as String?) ?? "Dynamic Audio Driver";

    if (connected) {
      _device = _device.copyWith(
        name: name.isNotEmpty ? name : "Connected Earphones",
        address: address,
        isConnected: true,
        leftBattery: battery >= 0 ? battery : -1,
        rightBattery: battery >= 0 ? battery : -1,
        caseBattery: battery >= 0 ? battery : -1,
        driverSize: driver,
        lastConnected: DateTime.now(),
      );
    } else {
      _device = _device.copyWith(
        name: "No Earphones Connected",
        address: "Turn on Bluetooth and connect earbuds",
        isConnected: false,
        leftBattery: -1,
        rightBattery: -1,
        caseBattery: -1,
      );
    }
    notifyListeners();
  }

  Future<void> refreshConnection({bool silent = false}) async {
    if (!silent) {
      _isScanning = true;
      notifyListeners();
    }

    try {
      final info = await _channel.invokeMethod<Map>('getConnectedTwsInfo');
      if (info != null) {
        _updateFromNativeData(Map<String, dynamic>.from(info));
      }

      final devices = await _channel.invokeListMethod<Map>('getPairedDevices');
      if (devices != null) {
        _pairedDevices = devices.map((d) => Map<String, dynamic>.from(d)).toList();
      }
    } catch (e) {
      debugPrint("Native Bluetooth check: $e");
    } finally {
      if (!silent) {
        _isScanning = false;
        notifyListeners();
      }
    }
  }

  void toggleConnection() {
    // Manually trigger immediate refresh / re-scan
    refreshConnection();
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
        final millibels = (_eqBands[i] * 100).toInt();
        await _channel.invokeMethod('setEqualizerBand', {'band': i, 'level': millibels});
      }
      await _channel.invokeMethod('setBassBoost', {'strength': (_bassBoost * 10)});
    } catch (_) {}
  }

  @override
  void dispose() {
    _autoConnectTimer?.cancel();
    super.dispose();
  }
}
