package com.mivi.twsmanager.tws_manager

import android.Manifest
import android.bluetooth.BluetoothA2dp
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothHeadset
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
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
    private var methodChannel: MethodChannel? = null
    private var audioTrack: AudioTrack? = null
    private var isPlayingBeep = false
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null

    private var a2dpProfile: BluetoothA2dp? = null
    private var headsetProfile: BluetoothHeadset? = null

    private val profileListener = object : BluetoothProfile.ServiceListener {
        override fun onServiceConnected(profile: Int, proxy: BluetoothProfile?) {
            if (profile == BluetoothProfile.A2DP) {
                a2dpProfile = proxy as? BluetoothA2dp
            } else if (profile == BluetoothProfile.HEADSET) {
                headsetProfile = proxy as? BluetoothHeadset
            }
            notifyFlutterStateChange()
        }

        override fun onServiceDisconnected(profile: Int) {
            if (profile == BluetoothProfile.A2DP) {
                a2dpProfile = null
            } else if (profile == BluetoothProfile.HEADSET) {
                headsetProfile = null
            }
            notifyFlutterStateChange()
        }
    }

    private val bluetoothReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                BluetoothDevice.ACTION_ACL_CONNECTED,
                BluetoothDevice.ACTION_ACL_DISCONNECTED,
                BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED,
                BluetoothAdapter.ACTION_STATE_CHANGED,
                BluetoothDevice.ACTION_BOND_STATE_CHANGED,
                "android.bluetooth.device.action.BATTERY_LEVEL_CHANGED",
                "android.bluetooth.a2dp.profile.action.CONNECTION_STATE_CHANGED",
                "android.bluetooth.headset.profile.action.CONNECTION_STATE_CHANGED" -> {
                    notifyFlutterStateChange()
                }
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
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

        initBluetoothProfiles()
        registerBluetoothReceiver()
    }

    private fun initBluetoothProfiles() {
        val adapter = getBluetoothAdapter() ?: return
        adapter.getProfileProxy(applicationContext, profileListener, BluetoothProfile.A2DP)
        adapter.getProfileProxy(applicationContext, profileListener, BluetoothProfile.HEADSET)
    }

    private fun registerBluetoothReceiver() {
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
            addAction(BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED)
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
            addAction("android.bluetooth.device.action.BATTERY_LEVEL_CHANGED")
            addAction("android.bluetooth.a2dp.profile.action.CONNECTION_STATE_CHANGED")
            addAction("android.bluetooth.headset.profile.action.CONNECTION_STATE_CHANGED")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(bluetoothReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(bluetoothReceiver, filter)
        }
    }

    private fun notifyFlutterStateChange() {
        runOnUiThread {
            try {
                val details = getConnectedTwsDetails()
                methodChannel?.invokeMethod("onBluetoothStateChanged", details)
            } catch (_: Exception) {}
        }
    }

    private fun getBluetoothAdapter(): BluetoothAdapter? {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        return bluetoothManager?.adapter ?: BluetoothAdapter.getDefaultAdapter()
    }

    private fun hasBluetoothPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun isDeviceConnected(device: BluetoothDevice): Boolean {
        if (!hasBluetoothPermission()) return false

        // Check if device is in A2DP connected devices list
        a2dpProfile?.let { a2dp ->
            if (a2dp.connectedDevices.any { it.address.equals(device.address, ignoreCase = true) }) {
                return true
            }
        }

        // Check if device is in Headset connected devices list
        headsetProfile?.let { headset ->
            if (headset.connectedDevices.any { it.address.equals(device.address, ignoreCase = true) }) {
                return true
            }
        }

        // Try reflection method `isConnected` on BluetoothDevice
        try {
            val method = device.javaClass.getMethod("isConnected")
            val connected = method.invoke(device) as? Boolean
            if (connected == true) return true
        } catch (_: Exception) {}

        return false
    }

    private fun getPairedBluetoothDevices(): List<Map<String, Any>> {
        val adapter = getBluetoothAdapter() ?: return emptyList()
        if (!hasBluetoothPermission()) return emptyList()

        val list = mutableListOf<Map<String, Any>>()
        for (device in adapter.bondedDevices) {
            val battery = getDeviceBatteryLevel(device)
            val connected = isDeviceConnected(device)
            val name = try { device.name ?: "Unknown Device" } catch (_: Exception) { "Unknown Device" }
            list.add(
                mapOf(
                    "name" to name,
                    "address" to device.address,
                    "batteryLevel" to battery,
                    "isConnected" to connected,
                    "type" to device.type
                )
            )
        }
        return list
    }

    private fun getConnectedTwsDetails(): Map<String, Any> {
        val adapter = getBluetoothAdapter()

        var connectedDevice: BluetoothDevice? = null
        var isConnected = false

        if (adapter != null && hasBluetoothPermission()) {
            // First check connected devices reported directly by A2DP profile
            a2dpProfile?.connectedDevices?.firstOrNull()?.let {
                connectedDevice = it
                isConnected = true
            }

            // If not found in A2DP, check Headset profile
            if (connectedDevice == null) {
                headsetProfile?.connectedDevices?.firstOrNull()?.let {
                    connectedDevice = it
                    isConnected = true
                }
            }

            // Fallback: check bonded devices using isConnected()
            if (connectedDevice == null) {
                for (dev in adapter.bondedDevices) {
                    if (isDeviceConnected(dev)) {
                        connectedDevice = dev
                        isConnected = true
                        break
                    }
                }
            }
        }

        if (connectedDevice != null && isConnected) {
            val device = connectedDevice!!
            val name = try { device.name ?: "Bluetooth Earphones" } catch (_: Exception) { "Bluetooth Earphones" }
            val address = device.address
            val battery = getDeviceBatteryLevel(device)
            val isMivi = name.contains("mivi", ignoreCase = true) || name.contains("duopods", ignoreCase = true)

            return mapOf(
                "name" to name,
                "address" to address,
                "batteryLevel" to battery,
                "isConnected" to true,
                "isMiviMatched" to isMivi,
                "bluetoothVersion" to "Bluetooth v5.3 / LE",
                "driverSize" to (if (isMivi) "13mm Dynamic Driver" else "Dynamic Audio Driver"),
                "encMode" to "AI-ENC Noise Filtering",
                "waterResistance" to "IPX4"
            )
        }

        // When NO device is actively connected
        return mapOf(
            "name" to "No Earphones Connected",
            "address" to "Waiting for Bluetooth connection...",
            "batteryLevel" to -1,
            "isConnected" to false,
            "isMiviMatched" to false,
            "bluetoothVersion" to "Bluetooth v5.3",
            "driverSize" to "Dynamic Driver",
            "encMode" to "AI-ENC Noise Filtering",
            "waterResistance" to "IPX4"
        )
    }

    private fun getDeviceBatteryLevel(device: BluetoothDevice): Int {
        try {
            // Official getBatteryLevel() on API 26+
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
                val freq = 2600.0
                val numSamples = sampleRate * (durationMs / 1000)
                val generatedSnd = ByteArray(2 * numSamples * 2)

                for (i in 0 until numSamples) {
                    val envelope = 0.5 * (1.0 + Math.sin(2.0 * Math.PI * 4.0 * i / sampleRate))
                    val sampleVal = (Math.sin(2.0 * Math.PI * freq * i / sampleRate) * 32767 * envelope).toInt().toShort()

                    val leftVal: Short = if (side == "LEFT" || side == "BOTH") sampleVal else 0
                    val rightVal: Short = if (side == "RIGHT" || side == "BOTH") sampleVal else 0

                    val idx = i * 4
                    generatedSnd[idx] = (leftVal.toInt() and 0x00ff).toByte()
                    generatedSnd[idx + 1] = ((leftVal.toInt() and 0xff00) ushr 8).toByte()
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
        try {
            unregisterReceiver(bluetoothReceiver)
        } catch (_: Exception) {}
        val adapter = getBluetoothAdapter()
        a2dpProfile?.let { adapter?.closeProfileProxy(BluetoothProfile.A2DP, it) }
        headsetProfile?.let { adapter?.closeProfileProxy(BluetoothProfile.HEADSET, it) }
        super.onDestroy()
    }
}
