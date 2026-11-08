import SwiftUI
import UIKit

/// Embeds the view controller an entry caches, so SwiftUI re-evaluation never recreates the screen.
@available(iOS 26.0, *)
struct ComposeScreenView: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
