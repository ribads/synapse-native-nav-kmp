import SwiftUI

/// Observable mirror of the host's navigation state. The host publishes whole per-tab paths and each screen's
/// chrome; SwiftUI assigns paths to `NavigationStack` paths and reports user-initiated pops back.
@available(iOS 26.0, *)
@MainActor
@Observable
final class NavigationModel: ShellSink {
    let tabs: [SNNTab]
    var selection: String
    var paths: [String: [RouteEntry]]
    var chromes: [Int64: SNNChrome] = [:]
    var tabBadges: [String: String] = [:]

    private let host: any SNNHost

    init(host: any SNNHost, tabs: [SNNTab]) {
        self.host = host
        self.tabs = tabs
        self.selection = tabs[0].identifier
        self.paths = Dictionary(uniqueKeysWithValues: tabs.map { ($0.identifier, [RouteEntry]()) })
    }

    func path(for tabId: String) -> [RouteEntry] {
        paths[tabId] ?? []
    }

    /// Applies a SwiftUI-side path mutation (back chevron, swipe-back) and reports what remains to the host.
    func applyNativePathChange(tabId: String, newPath: [RouteEntry]) {
        paths[tabId] = newPath
        host.nativeStackChanged(forTab: tabId, entries: newPath.map(\.entry))
        pruneChromes()
    }

    func pathChanged(tabId: String, entries: [any SNNEntry]) {
        let newPath = entries.map { RouteEntry(entry: $0) }
        if paths[tabId] != newPath {
            paths[tabId] = newPath
            pruneChromes()
        }
    }

    func tabSelectionRequested(tabId: String) {
        if selection != tabId {
            selection = tabId
        }
    }

    func tabBadgeChanged(tabId: String, badge: String?) {
        tabBadges[tabId] = badge
    }

    func chromeChanged(entryUid: Int64, chrome: SNNChrome?) {
        chromes[entryUid] = chrome
    }

    /// Drops chrome mirrored for pushed entries no longer on any path. Tab roots are permanent.
    private func pruneChromes() {
        let pushedUids = paths.values.flatMap { $0.map(\.id) }
        let liveUids = Set(pushedUids + tabs.map(\.root.uid))
        chromes = chromes.filter { liveUids.contains($0.key) }
    }
}
