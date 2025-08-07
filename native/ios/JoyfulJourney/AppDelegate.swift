import UIKit
import Turbo

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Turbo
        configureTurbo()
        
        // Setup window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        
        // Configure appearance
        configureAppearance()
        
        return true
    }
    
    private func configureTurbo() {
        // Configure Turbo debugging for development
        #if DEBUG
        Turbo.config.debugLoggingEnabled = true
        #endif
        
        // Set user agent
        Turbo.config.userAgent = "JoyfulJourney iOS (Turbo Native)"
        
        // Configure path configuration cache
        Turbo.config.pathConfiguration.sources = [
            .server(URL(string: "\(Server.baseURL)/turbo/ios_path_configuration")!)
        ]
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set tint color for the app
        window?.tintColor = UIColor.systemBlue
    }
}

// MARK: - Server Configuration
struct Server {
    #if DEBUG
    static let baseURL = "http://localhost:3000"
    #else
    static let baseURL = "https://joyfuljourney.com"
    #endif
    
    static var rootURL: URL {
        URL(string: baseURL)!
    }
    
    static func url(for path: String) -> URL {
        URL(string: baseURL + path)!
    }
}