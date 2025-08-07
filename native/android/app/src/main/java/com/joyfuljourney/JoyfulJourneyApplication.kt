package com.joyfuljourney

import android.app.Application
import dev.hotwire.turbo.config.TurboConfig

class JoyfulJourneyApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        
        // Initialize Authentication Manager
        AuthenticationManager.init(this)
        
        // Configure Turbo
        configureTurbo()
    }
    
    private fun configureTurbo() {
        // Set debug logging for development
        TurboConfig.debugLoggingEnabled = BuildConfig.DEBUG
        
        // Configure user agent
        TurboConfig.userAgent = "JoyfulJourney Android (Turbo Native)"
        
        // Configure path configuration
        TurboConfig.pathConfiguration.apply {
            load(
                context = this@JoyfulJourneyApplication,
                location = TurboConfig.PathConfiguration.Location(
                    remoteUrl = "${BuildConfig.BASE_URL}/turbo/android_path_configuration"
                )
            )
        }
    }
}