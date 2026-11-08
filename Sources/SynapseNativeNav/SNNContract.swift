import UIKit

/// One hosted screen, implemented by the host's navigation layer.
@objc(SNNEntry)
@MainActor
public protocol SNNEntry: NSObjectProtocol {
    var uid: Int64 { get }

    /// True for a screen that fills the display: the shell shows no bars over it and offers no system back.
    var isFullScreen: Bool { get }

    /// The same instance on every call, so SwiftUI re-evaluation never rebuilds the screen.
    func viewController() -> UIViewController

    /// How far the native bars overlap the screen, in points.
    @objc(setContentInsetsTop:bottom:)
    func setContentInsets(top: Double, bottom: Double)

    @objc(performAction:)
    func performAction(_ actionId: String)

    func performLeadingAction()
}

/// Told about what the user does natively: pops, by the back chevron and swipe-back, and choosing a tab.
@objc(SNNHost)
@MainActor
public protocol SNNHost: NSObjectProtocol {
    @objc(nativeStackChangedForTab:entries:)
    func nativeStackChanged(forTab tabId: String, entries: [any SNNEntry])

    @objc(tabSelected:)
    func tabSelected(_ tabId: String)
}
