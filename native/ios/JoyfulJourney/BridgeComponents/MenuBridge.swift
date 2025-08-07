import Foundation
import WebKit

class MenuBridge: NSObject, WKScriptMessageHandler {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "menu",
              let body = message.body as? [String: Any] else { return }
        
        if let action = body["action"] as? String {
            switch action {
            case "updateMenuItems":
                if let items = body["items"] as? [[String: Any]] {
                    updateMenuItems(items)
                }
            case "selectMenuItem":
                if let itemData = body["data"] as? [String: Any] {
                    handleMenuItemSelection(itemData)
                }
            default:
                break
            }
        }
    }
    
    private func updateMenuItems(_ items: [[String: Any]]) {
        // Create native menu if needed
        DispatchQueue.main.async { [weak self] in
            guard let viewController = self?.viewController else { return }
            
            // Create menu button if not exists
            if viewController.navigationItem.rightBarButtonItem == nil {
                let menuButton = UIBarButtonItem(
                    image: UIImage(systemName: "ellipsis.circle"),
                    style: .plain,
                    target: self,
                    action: #selector(self?.showMenu)
                )
                viewController.navigationItem.rightBarButtonItem = menuButton
            }
        }
    }
    
    @objc private func showMenu() {
        guard let viewController = viewController else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add menu items based on authentication state
        if AuthenticationManager.shared.currentUser != nil {
            alertController.addAction(UIAlertAction(title: "New Post", style: .default) { _ in
                self.navigateTo("/posts/new", presentation: .modal)
            })
            
            alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                self.navigateTo("/settings", presentation: .push)
            })
            
            alertController.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
                self.logout()
            })
        } else {
            alertController.addAction(UIAlertAction(title: "Login", style: .default) { _ in
                self.navigateTo("/login", presentation: .modal)
            })
            
            alertController.addAction(UIAlertAction(title: "Sign Up", style: .default) { _ in
                self.navigateTo("/users/new?claimed=true", presentation: .modal)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alertController.popoverPresentationController {
            popover.barButtonItem = viewController.navigationItem.rightBarButtonItem
        }
        
        viewController.present(alertController, animated: true)
    }
    
    private func handleMenuItemSelection(_ data: [String: Any]) {
        guard let path = data["path"] as? String else { return }
        
        let method = data["method"] as? String ?? "get"
        let presentation = data["presentation"] as? String ?? "push"
        
        if method == "post" && path == "/logout" {
            logout()
        } else {
            navigateTo(path, presentation: presentation == "modal" ? .modal : .push)
        }
    }
    
    private func navigateTo(_ path: String, presentation: NavigationPresentation) {
        guard let viewController = viewController,
              let session = (viewController as? Visitable)?.visitableDelegate as? Session else { return }
        
        let url = Server.url(for: path)
        
        switch presentation {
        case .modal:
            let modalViewController = VisitableViewController(url: url)
            let navigationController = UINavigationController(rootViewController: modalViewController)
            
            modalViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(dismissModal)
            )
            
            viewController.present(navigationController, animated: true)
            
        case .push:
            session.visit(url)
        }
    }
    
    @objc private func dismissModal() {
        viewController?.dismiss(animated: true)
    }
    
    private func logout() {
        AuthenticationManager.shared.logout()
        
        // Navigate to login
        navigateTo("/login", presentation: .modal)
    }
}

enum NavigationPresentation {
    case modal
    case push
}