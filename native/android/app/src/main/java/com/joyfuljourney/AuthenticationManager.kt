package com.joyfuljourney

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST

object AuthenticationManager {
    private const val PREFS_NAME = "JoyfulJourneyPrefs"
    private const val KEY_AUTH_TOKEN = "auth_token"
    private const val KEY_USER_DATA = "user_data"
    
    private lateinit var sharedPreferences: SharedPreferences
    private val gson = Gson()
    
    var currentUser: User? = null
        private set
    
    fun init(context: Context) {
        // Create encrypted shared preferences
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()
        
        sharedPreferences = EncryptedSharedPreferences.create(
            context,
            PREFS_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
        
        // Load saved user data
        loadUserData()
    }
    
    fun isAuthenticated(): Boolean {
        return getAuthToken() != null
    }
    
    fun getAuthToken(): String? {
        return sharedPreferences.getString(KEY_AUTH_TOKEN, null)
    }
    
    private fun saveAuthToken(token: String) {
        sharedPreferences.edit().putString(KEY_AUTH_TOKEN, token).apply()
    }
    
    private fun clearAuthToken() {
        sharedPreferences.edit().remove(KEY_AUTH_TOKEN).apply()
    }
    
    private fun saveUserData(user: User) {
        val userJson = gson.toJson(user)
        sharedPreferences.edit().putString(KEY_USER_DATA, userJson).apply()
        currentUser = user
    }
    
    private fun loadUserData() {
        val userJson = sharedPreferences.getString(KEY_USER_DATA, null)
        if (userJson != null) {
            currentUser = gson.fromJson(userJson, User::class.java)
        }
    }
    
    private fun clearUserData() {
        sharedPreferences.edit().remove(KEY_USER_DATA).apply()
        currentUser = null
    }
    
    suspend fun login(username: String, password: String): Result<User> {
        return withContext(Dispatchers.IO) {
            try {
                val response = ApiService.create().login(
                    LoginRequest(username, password)
                )
                
                // Save token and user data
                saveAuthToken(response.token)
                saveUserData(response.user)
                
                Result.success(response.user)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
    
    fun logout() {
        clearAuthToken()
        clearUserData()
    }
}

// Data classes
data class User(
    val id: Int,
    val username: String,
    val firstName: String,
    val lastName: String,
    val name: String,
    val role: String,
    val claimed: Boolean
)

data class LoginRequest(
    val username: String,
    val password: String
)

data class LoginResponse(
    val token: String,
    val user: User
)

// API Service
interface ApiService {
    @POST("api/v1/login")
    suspend fun login(@Body request: LoginRequest): LoginResponse
    
    companion object {
        fun create(): ApiService {
            val retrofit = Retrofit.Builder()
                .baseUrl(BuildConfig.BASE_URL)
                .addConverterFactory(GsonConverterFactory.create())
                .build()
            
            return retrofit.create(ApiService::class.java)
        }
    }
}