import Foundation
import WebKit

class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private let tokenKey = "JoyfulJourneyAuthToken"
    private let userDefaultsKey = "JoyfulJourneyUserData"
    
    private init() {}
    
    // MARK: - Token Management
    
    var authToken: String? {
        get {
            KeychainHelper.shared.read(service: "JoyfulJourney", account: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainHelper.shared.save(token, service: "JoyfulJourney", account: tokenKey)
            } else {
                KeychainHelper.shared.delete(service: "JoyfulJourney", account: tokenKey)
            }
        }
    }
    
    // MARK: - User Data
    
    var currentUser: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            if let user = newValue,
               let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        }
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = Server.url(for: "/api/v1/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(AuthenticationError.invalidCredentials))
                }
                return
            }
            
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                self?.authToken = loginResponse.token
                self?.currentUser = loginResponse.user
                
                DispatchQueue.main.async {
                    completion(.success(loginResponse.user))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func logout() {
        // Clear token
        authToken = nil
        currentUser = nil
        
        // Clear web view cookies
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0),
            completionHandler: {}
        )
        
        // Post notification
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    // MARK: - Web View Configuration
    
    func configureWebView(_ webView: WKWebView) {
        // Add authentication token to headers if available
        if let token = authToken {
            let script = """
                (function() {
                    var xhr = XMLHttpRequest.prototype.open;
                    XMLHttpRequest.prototype.open = function() {
                        var result = xhr.apply(this, arguments);
                        this.setRequestHeader('Authorization', 'Bearer \(token)');
                        return result;
                    };
                    
                    // Store token in localStorage for the web app
                    localStorage.setItem('authToken', '\(token)');
                })();
            """
            
            let userScript = WKUserScript(
                source: script,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            
            webView.configuration.userContentController.addUserScript(userScript)
        }
    }
}

// MARK: - Models

struct User: Codable {
    let id: Int
    let username: String
    let firstName: String
    let lastName: String
    let name: String
    let role: String
    let claimed: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, username, name, role, claimed
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

// MARK: - Errors

enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .networkError:
            return "Network error. Please try again."
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}