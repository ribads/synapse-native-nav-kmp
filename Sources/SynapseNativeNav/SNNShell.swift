import SwiftUI
import UIKit

@MainActor
protocol ShellSink: AnyObject {
    func pathChanged(tabId: String, entries: [any SNNEntry])
    func tabSelectionRequested(tabId: String)
    func tabBadgeChanged(tabId: String, badge: String?)
    func chromeChanged(entryUid: Int64, chrome: SNNChrome?)
}

/// The iOS 26 Liquid Glass shell: a native `TabView` with one `NavigationStack` per tab. The system renders all
/// the chrome; each screen's content comes from its `SNNEntry`.
@objc(SNNShell)
@MainActor
public final class SNNShell: NSObject {
    private let items: [SNNTabItem]
    private weak var sink: (any ShellSink)?

    /// False below iOS 26, where the host keeps its own root view controller.
    @objc public nonisolated static func isSupported() -> Bool {
        if #available(iOS 26.0, *) { return true }
        return false
    }

    /// The tab bar's items in display order, at least one of them an `SNNTab`. The first tab starts selected.
    @objc(initWithItems:)
    public init(items: [SNNTabItem]) {
        self.items = items
    }

    /// Builds the shell's root. Call once, after checking `isSupported()`.
    @objc(makeViewControllerWithHost:)
    public func makeViewController(host: any SNNHost) -> UIViewController {
        guard #available(iOS 26.0, *) else {
            preconditionFailure("SNNShell needs iOS 26: check isSupported() first")
        }
        let model = NavigationModel(host: host, items: items)
        sink = model
        return UIHostingController(rootView: NativeShellView(model: model))
    }

    /// Replaces the tab's pushed screens, wholesale. The tab's root is never part of the path.
    @objc(setPath:forTab:)
    public func setPath(_ entries: [any SNNEntry], forTab tabId: String) {
        sink?.pathChanged(tabId: tabId, entries: entries)
    }

    @objc(selectTab:)
    public func selectTab(_ tabId: String) {
        sink?.tabSelectionRequested(tabId: tabId)
    }

    @objc(setBadge:forTab:)
    public func setBadge(_ badge: String?, forTab tabId: String) {
        sink?.tabBadgeChanged(tabId: tabId, badge: badge)
    }

    @objc(setChrome:forEntryUid:)
    public func setChrome(_ chrome: SNNChrome?, forEntryUid uid: Int64) {
        sink?.chromeChanged(entryUid: uid, chrome: chrome)
    }
}
