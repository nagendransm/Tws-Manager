package com.mivi.twsmanager.tws_manager

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mivi.twsmanager/bluetooth"
    private var audioTrack: AudioTrack? = null
    private var isPlayingBeep = false
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPairedDevices" -> {
                    try {
                        val devices = getPairedBluetoothDevices()
                        result.success(devices)
                    } catch (e: Exception) {
                        result.error("BLUETOOTH_ERROR", e.localizedMessage, null)
                    }
                }
                "getConnectedTwsInfo" -> {
                    try {
                        val info = getConnectedTwsDetails()
                        result.success(info)
                    } catch (e: Exception) {
                        result.error("INFO_ERROR", e.localizedMessage, null)
                    }
                }
                "playFinderBeep" -> {
                    val channelSide = call.argument<String>("side") ?: "BOTH"
                    val durationMs = call.argument<Int>("durationMs") ?: 3000
                    playBeepTone(channelSide, durationMs)
                    result.success(true)
                }
                "stopFinderBeep" -> {
                    stopBeepTone()
                    result.success(true)
                }
                "setEqualizerBand" -> {
                    val band = call.argument<Int>("band") ?: 0
                    val level = call.argument<Int>("level") ?: 0
                    val success = applyEqualizerBand(band, level)
                    result.success(success)
                }
                "setBassBoost" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    val success = applyBassBoost(strength)
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasBluetoothPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun getPairedBluetoothDevices(): List<Map<String, Any>> {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        val adapter = bluetoothManager?.adapter ?: BluetoothAdapter.getDefaultAdapter() ?: return emptyList()

        if (!hasBluetoothPermission()) {
            return emptyList()
        }

        val list = mutableListOf<Map<String, Any>>()
        for (device in adapter.bondedDevices) {
            val battery = getDeviceBatteryLevel(device)
            val isMivi = device.name?.contains("mivi", ignoreCase = true) == true ||
                         device.name?.contains("duopods", ignoreCase = true) == true
            list.add(
                mapOf(
                    "name" to (device.name ?: "Unknown Bluetooth Device"),
                    "address" to device.address,
                    "batteryLevel" to battery,
                    "isMivi" to isMivi,
                    "type" to device.type
                )
            )
        }
        return list
    }

    private fun getConnectedTwsDetails(): Map<String, Any> {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        val adapter = bluetoothManager?.adapter ?: BluetoothAdapter.getDefaultAdapter()

        var connectedName = "Mivi DuoPods K2"
        var connectedAddress = "Connected (Bluetooth 5.3)"
        var batteryLevel = 85
        var isConnected = false
        var isMiviMatched = false

        if (adapter != null && hasBluetoothPermission()) {
            for (device in adapter.bondedDevices) {
                val name = device.name ?: ""
                val isMivi = name.contains("mivi", ignoreCase = true) || name.contains("duopods", ignoreCase = true)
                val battery = getDeviceBatteryLevel(device)

                // Check profile connection state for A2DP or HEADSET
                val a2dpState = adapter.getProfileConnectionState(BluetoothProfile.A2DP)
                val headsetState = adapter.getProfileConnectionState(BluetoothProfile.HEADSET)
                val active = (a2dpState == BluetoothProfile.STATE_CONNECTED || headsetState == BluetoothProfile.STATE_CONNECTED)

                if (isMivi) {
                    connectedName = name
                    connectedAddress = device.address
                    if (battery in 0..100) batteryLevel = battery
                    isConnected = active
                    isMiviMatched = true
                    break
                } else if (active && !isMiviMatched) {
                    connectedName = name
                    connectedAddress = device.address
                    if (battery in 0..100) batteryLevel = battery
                    isConnected = true
                }
            }
        }

        return mapOf(
            "name" to connectedName,
            "address" to connectedAddress,
            "batteryLevel" to batteryLevel,
            "isConnected" to isConnected,
            "isMiviMatched" to isMiviMatched,
            "bluetoothVersion" to "Bluetooth v5.3",
            "driverSize" to "13mm Dynamic Drivers",
            "encMode" to "AI-ENC (Dual HD Mics)",
            "ancMode" to "N/A (Hardware ENC for Calls)",
            "lowLatencyMode" to "Battle Mode (50ms)",
            "waterResistance" to "IPX4",
            "totalPlaytimeHours" to 40
        )
    }

    private fun getDeviceBatteryLevel(device: BluetoothDevice): Int {
        try {
            // First try official getBatteryLevel() on API 26+
            val method = device.javaClass.getMethod("getBatteryLevel")
            val level = method.invoke(device) as? Int
            if (level != null && level >= 0) {
                return level
            }
        } catch (_: Exception) {}
        return -1
    }

    private fun playBeepTone(side: String, durationMs: Int) {
        stopBeepTone()
        isPlayingBeep = true

        thread {
            try {
                val sampleRate = 44100
                val freq = 2600.0 // High pitch chirp for earbud localization
                val numSamples = sampleRate * (durationMs / 1000)
                val generatedSnd = ByteArray(2 * numSamples * 2) // Stereo 16-bit

                for (i in 0 until numSamples) {
                    // Pulsating chirp envelope
                    val envelope = 0.5 * (1.0 + Math.sin(2.0 * Math.PI * 4.0 * i / sampleRate))
                    val sampleVal = (Math.sin(2.0 * Math.PI * freq * i / sampleRate) * 32767 * envelope).toInt().toShort()

                    val leftVal: Short = if (side == "LEFT" || side == "BOTH") sampleVal else 0
                    val rightVal: Short = if (side == "RIGHT" || side == "BOTH") sampleVal else 0

                    val idx = i * 4
                    // Left channel
                    generatedSnd[idx] = (leftVal.toInt() and 0x00ff).toByte()
                    generatedSnd[idx + 1] = ((leftVal.toInt() and 0xff00) ushr 8).toByte()
                    // Right channel
                    generatedSnd[idx + 2] = (rightVal.toInt() and 0x00ff).toByte()
                    generatedSnd[idx + 3] = ((rightVal.toInt() and 0xff00) ushr 8).toByte()
                }

                audioTrack = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
                            .build()
                    )
                    .setBufferSizeInBytes(generatedSnd.size)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()

                audioTrack?.write(generatedSnd, 0, generatedSnd.size)
                audioTrack?.play()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun stopBeepTone() {
        isPlayingBeep = false
        try {
            audioTrack?.stop()
            audioTrack?.release()
            audioTrack = null
        } catch (_: Exception) {}
    }

    private fun applyEqualizerBand(band: Int, level: Int): Boolean {
        return try {
            if (equalizer == null) {
                equalizer = Equalizer(0, 0)
                equalizer?.enabled = true
            }
            if (band < (equalizer?.numberOfBands ?: 0)) {
                equalizer?.setBandLevel(band.toShort(), level.toShort())
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun applyBassBoost(strength: Int): Boolean {
        return try {
            if (bassBoost == null) {
                bassBoost = BassBoost(0, 0)
                bassBoost?.enabled = true
            }
            bassBoost?.setStrength(strength.toShort())
            true
        } catch (e: Exception) {
            false
        }
    }

    override fun onDestroy() {
        stopBeepTone()
        equalizer?.release()
        bassBoost?.release()
        super.onDestroy()
    }
}
