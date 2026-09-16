package com.mario.totp

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.view.WindowManager.LayoutParams
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    companion object {
        private const val Channel = "android_keystore"
        private const val KeyStoreSign = "AndroidKeyStore"
        private const val KeyAlias = "totp_secret_key"
        private const val Transformation = "AES/GCM/NoPadding"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // 添加 FLAG_SECURE，禁用截屏和录屏
        window.addFlags(LayoutParams.FLAG_SECURE)
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            Channel
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "createKey" -> {
                        result.success(createKey())
                    }

                    "encrypt" -> {
                        val data = call.arguments as ByteArray
                        result.success(encrypt(data))
                    }

                    "decrypt" -> {
                        val data = call.arguments as ByteArray
                        result.success(decrypt(data))
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error("KeyStore_Error", e.message, null)
            }
        }
    }

    private fun createKey() {
        val keyStore = KeyStore.getInstance(KeyStoreSign)
        keyStore.load(null)

        if (keyStore.containsAlias(KeyAlias)) {
            return
        }

        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KeyStoreSign
        )

        val keySpec = KeyGenParameterSpec.Builder(
            KeyAlias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setKeySize(256)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .build()

        keyGenerator.init(keySpec)

        keyGenerator.generateKey()
    }

    private fun encrypt(data: ByteArray): ByteArray {
        val keyStore = KeyStore.getInstance(KeyStoreSign)
        keyStore.load(null)
        if (!keyStore.containsAlias(KeyAlias)) {
            throw IllegalStateException("Key not exist")
        }
        val k = keyStore.getKey(KeyAlias, null) as SecretKey

        val cipher = Cipher.getInstance(Transformation)
        cipher.init(Cipher.ENCRYPT_MODE, k)
        val ciphertext = cipher.doFinal(data)

        return cipher.iv + ciphertext
    }

    private fun decrypt(data: ByteArray): ByteArray {
        if (data.size < 12) {
            throw IllegalArgumentException("Invalid encrypted data")
        }

        val iv = data.copyOfRange(0, 12)
        val ciphertext = data.copyOfRange(12, data.size)

        val keyStore = KeyStore.getInstance(KeyStoreSign)
        keyStore.load(null)
        if (!keyStore.containsAlias(KeyAlias)) {
            throw IllegalStateException("Key not exist")
        }
        val k = keyStore.getKey(KeyAlias, null) as SecretKey

        val cipher = Cipher.getInstance(Transformation)
        val spec = GCMParameterSpec(128, iv)
        cipher.init(Cipher.DECRYPT_MODE, k, spec)

        return cipher.doFinal(ciphertext)
    }
}
