import UIKit
import Turbo

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let session = Session()
    private var isAuthenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        // Configure session
        configureSession()
        
        // Setup tabs
        setupTabs()
        
        // Check authentication status
        checkAuthentication()
    }
    
    private func configureSession() {
        session.delegate = self
        session.pathConfiguration = PathConfiguration(sources: [
            .server(URL(string: "\(Server.baseURL)/turbo/ios_path_configuration")!)
        ])
        
        // Configure web view
        session.webView.customUserAgent = "JoyfulJourney iOS (Turbo Native)"
        session.webView.allowsBackForwardNavigationGestures = true
    }
    
    private func setupTabs() {
        let homeTab = createNavigationController(
            for: Server.rootURL,
            title: "Home",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        
        let postsTab = createNavigationController(
            for: Server.url(for: "/posts"),
            title: "Posts",
            image: UIImage(systemName: "square.and.pencil"),
            tag: 1
        )
        
        let timelineTab = createNavigationController(
            for: Server.url(for: "/timeline"),
            title: "Timeline",
            image: UIImage(systemName: "clock.fill"),
            tag: 2
        )
        
        let familiesTab = createNavigationController(
            for: Server.url(for: "/families"),
            title: "Family",
            image: UIImage(systemName: "person.3.fill"),
            tag: 3
        )
        
        let profileTab = createNavigationController(
            for: Server.url(for: "/users/me"),
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle.fill"),
            tag: 4
        )
        
        viewControllers = [homeTab, postsTab, timelineTab, familiesTab, profileTab]
    }
    
    private func createNavigationController(for url: URL, title: String, image: UIImage?, tag: Int) -> UINavigationController {
        let viewController = VisitableViewController(url: url)
        viewController.title = title
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        
        return navigationController
    }
    
    private func checkAuthentication() {
        // Check if user has stored authentication token
        if let token = AuthenticationManager.shared.authToken {
            isAuthenticated = true
            // Add token to session headers
            session.webView.customUserAgent = "JoyfulJourney iOS (Turbo Native) Token:\(token)"
        } else {
            // Show login if not authenticated
            presentLoginModal()
        }
    }
    
    private func presentLoginModal() {
        let loginURL = Server.url(for: "/login")
        let loginViewController = VisitableViewController(url: loginURL)
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController,
           let visitable = navController.topViewController as? Visitable {
            // Refresh the current tab when reselected
            if navController.viewControllers.count == 1 {
                session.reload()
            }
        }
    }
}

// MARK: - SessionDelegate

extension MainTabBarController: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        // Get the current navigation controller
        guard let navigationController = selectedViewController as? UINavigationController else { return }
        
        // Check if this is a modal presentation
        if proposal.properties["presentation"] as? String == "modal" {
            presentModalViewController(for: proposal)
        } else {
            // Push or replace in current navigation stack
            let viewController = VisitableViewController(url: proposal.url)
            
            if proposal.properties["presentation"] as? String == "replace" {
                navigationController.setViewControllers([viewController], animated: true)
            } else {
                navigationController.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        if let turboError = error as? TurboError {
            switch turboError {
            case .http(let statusCode):
                if statusCode == 401 {
                    // Unauthorized - show login
                    presentLoginModal()
                } else {
                    showError(error)
                }
            default:
                showError(error)
            }
        } else {
            showError(error)
        }
    }
    
    func sessionWebViewProcessDidTerminate(_ session: Session) {
        session.reload()
    }
    
    private func presentModalViewController(for proposal: VisitProposal) {
        let viewController = VisitableViewController(url: proposal.url)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        // Add close button for modals
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissModal)
        )
        
        // Configure modal style if specified
        if let modalStyle = proposal.properties["modal_style"] as? String {
            switch modalStyle {
            case "form_sheet":
                navigationController.modalPresentationStyle = .formSheet
            case "page_sheet":
                navigationController.modalPresentationStyle = .pageSheet
            default:
                navigationController.modalPresentationStyle = .automatic
            }
        }
        
        present(navigationController, animated: true)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}