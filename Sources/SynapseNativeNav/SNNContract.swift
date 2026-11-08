import UIKit

/// One hosted screen, implemented by the host's navigation layer.
@objc(SNNEntry)
@MainActor
public protocol SNNEntry: NSObjectProtocol {
    var uid: Int64 { get }

    /// The same instance on every call, so SwiftUI re-evaluation never rebuilds the screen.
    func viewController() -> UIViewController

    /// How far the native bars overlap the screen, in points.
    @objc(setContentInsetsTop:bottom:)
    func setContentInsets(top: Double, bottom: Double)

    @objc(performAction:)
    func performAction(_ actionId: String)

    func performLeadingAction()
}

/// Told about the pops the user makes natively: the back chevron and swipe-back.
@objc(SNNHost)
@MainActor
public protocol SNNHost: NSObjectProtocol {
    @objc(nativeStackChangedForTab:entries:)
    func nativeStackChanged(forTab tabId: String, entries: [any SNNEntry])
}
