import UIKit
import WebKit
import PhotosUI

class CameraBridge: NSObject {
    weak var viewController: UIViewController?
    weak var webView: WKWebView?
    private var photoPickerCallback: ((String) -> Void)?
    
    init(viewController: UIViewController, webView: WKWebView) {
        self.viewController = viewController
        self.webView = webView
        super.init()
    }
}

// MARK: - WKScriptMessageHandler

extension CameraBridge: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "camera",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }
        
        switch action {
        case "requestPhoto":
            handlePhotoRequest(body)
        default:
            break
        }
    }
    
    private func handlePhotoRequest(_ data: [String: Any]) {
        let source = data["source"] as? String ?? "both"
        let allowsMultiple = data["allowsMultiple"] as? Bool ?? false
        let inputId = data["inputId"] as? String ?? ""
        
        DispatchQueue.main.async { [weak self] in
            if source == "camera" {
                self?.presentCamera(inputId: inputId)
            } else if source == "gallery" {
                self?.presentPhotoLibrary(allowsMultiple: allowsMultiple, inputId: inputId)
            } else {
                self?.presentSourcePicker(allowsMultiple: allowsMultiple, inputId: inputId)
            }
        }
    }
    
    private func presentSourcePicker(allowsMultiple: Bool, inputId: String) {
        let alertController = UIAlertController(title: "Choose Photo", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentCamera(inputId: inputId)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentPhotoLibrary(allowsMultiple: allowsMultiple, inputId: inputId)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = viewController?.view
            popover.sourceRect = CGRect(x: viewController?.view.bounds.midX ?? 0, 
                                       y: viewController?.view.bounds.midY ?? 0, 
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController?.present(alertController, animated: true)
    }
    
    private func presentCamera(inputId: String) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.view.tag = inputId.hashValue
        
        viewController?.present(imagePickerController, animated: true)
    }
    
    private func presentPhotoLibrary(allowsMultiple: Bool, inputId: String) {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = allowsMultiple ? 0 : 1
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            picker.view.tag = inputId.hashValue
            
            viewController?.present(picker, animated: true)
        } else {
            // Fallback to UIImagePickerController for older iOS versions
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.view.tag = inputId.hashValue
            
            viewController?.present(imagePickerController, animated: true)
        }
    }
    
    private func sendPhotoToWebView(image: UIImage, inputId: String) {
        guard let webView = webView else { return }
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let base64String = imageData.base64EncodedString()
        
        // Send to JavaScript
        let javascript = """
            (function() {
                const bridge = document.querySelector('[data-bridge-component="camera"]');
                if (bridge && bridge.setPhoto) {
                    bridge.setPhoto({
                        inputId: '\(inputId)',
                        base64: '\(base64String)',
                        filename: 'photo_\(Date().timeIntervalSince1970).jpg'
                    });
                }
            })();
        """
        
        webView.evaluateJavaScript(javascript) { result, error in
            if let error = error {
                print("Error sending photo to web view: \(error)")
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CameraBridge: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, 
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
        
        let inputId = String(picker.view.tag)
        sendPhotoToWebView(image: image, inputId: inputId)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14, *)
extension CameraBridge: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let inputId = String(picker.view.tag)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.sendPhotoToWebView(image: image, inputId: inputId)
                        }
                    }
                }
            }
        }
    }
}