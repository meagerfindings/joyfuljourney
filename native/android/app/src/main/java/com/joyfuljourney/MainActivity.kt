package com.joyfuljourney

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.findNavController
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.joyfuljourney.databinding.ActivityMainBinding
import dev.hotwire.turbo.activities.TurboActivity
import dev.hotwire.turbo.delegates.TurboActivityDelegate

class MainActivity : AppCompatActivity(), TurboActivity {
    
    private lateinit var binding: ActivityMainBinding
    override lateinit var delegate: TurboActivityDelegate
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        // Initialize Turbo
        delegate = TurboActivityDelegate(this, R.id.nav_host_fragment)
        
        // Setup bottom navigation
        setupBottomNavigation()
        
        // Check authentication
        checkAuthentication()
    }
    
    private fun setupBottomNavigation() {
        val navView: BottomNavigationView = binding.navView
        val navController = findNavController(R.id.nav_host_fragment)
        
        // Configure navigation items
        navView.menu.clear()
        navView.menu.add(0, R.id.navigation_home, 0, "Home").setIcon(R.drawable.ic_home)
        navView.menu.add(0, R.id.navigation_posts, 1, "Posts").setIcon(R.drawable.ic_edit)
        navView.menu.add(0, R.id.navigation_timeline, 2, "Timeline").setIcon(R.drawable.ic_schedule)
        navView.menu.add(0, R.id.navigation_family, 3, "Family").setIcon(R.drawable.ic_group)
        navView.menu.add(0, R.id.navigation_profile, 4, "Profile").setIcon(R.drawable.ic_person)
        
        navView.setupWithNavController(navController)
        
        // Handle navigation item selection
        navView.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.navigation_home -> {
                    delegate.navigate("${BuildConfig.BASE_URL}/")
                    true
                }
                R.id.navigation_posts -> {
                    delegate.navigate("${BuildConfig.BASE_URL}/posts")
                    true
                }
                R.id.navigation_timeline -> {
                    delegate.navigate("${BuildConfig.BASE_URL}/timeline")
                    true
                }
                R.id.navigation_family -> {
                    delegate.navigate("${BuildConfig.BASE_URL}/families")
                    true
                }
                R.id.navigation_profile -> {
                    val userId = AuthenticationManager.currentUser?.id
                    if (userId != null) {
                        delegate.navigate("${BuildConfig.BASE_URL}/users/$userId")
                    } else {
                        delegate.navigate("${BuildConfig.BASE_URL}/login")
                    }
                    true
                }
                else -> false
            }
        }
    }
    
    private fun checkAuthentication() {
        if (!AuthenticationManager.isAuthenticated()) {
            // Show login screen
            delegate.navigate("${BuildConfig.BASE_URL}/login")
        }
    }
    
    override fun onRestart() {
        super.onRestart()
        delegate.onRestart()
    }
}