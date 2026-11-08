import UIKit
import XCTest
@testable import SynapseNativeNav

@MainActor
private final class FakeEntry: NSObject, SNNEntry {
    let uid: Int64
    let isFullScreen = false

    init(uid: Int64) {
        self.uid = uid
    }

    func viewController() -> UIViewController { UIViewController() }
    func setContentInsets(top: Double, bottom: Double) {}
    func performAction(_ actionId: String) {}
    func performLeadingAction() {}
}

@MainActor
private final class FakeHost: NSObject, SNNHost {
    var reported: [[Int64]] = []
    var selected: [String] = []

    func nativeStackChanged(forTab tabId: String, entries: [any SNNEntry]) {
        reported.append(entries.map(\.uid))
    }

    func tabSelected(_ tabId: String) {
        selected.append(tabId)
    }
}

@available(iOS 26.0, *)
@MainActor
final class NavigationModelTests: XCTestCase {

    private let host = FakeHost()
    private let chrome = SNNChrome(title: "Title", subtitle: nil, titleDisplay: .inline, leading: .back, actions: [])

    private func tab(_ identifier: String, rootUid: Int64) -> SNNTab {
        SNNTab(identifier: identifier, title: identifier, sfSymbol: nil, image: nil, root: FakeEntry(uid: rootUid))
    }

    private func model() -> NavigationModel {
        NavigationModel(host: host, tabs: [tab("home", rootUid: 1), tab("memos", rootUid: 2)])
    }

    func testTheFirstTabStartsSelectedWithEmptyPaths() {
        let model = model()

        XCTAssertEqual(model.selection, "home")
        XCTAssertEqual(model.path(for: "home"), [])
        XCTAssertEqual(model.path(for: "memos"), [])
    }

    func testChoosingATabIsReportedOnce() {
        let model = model()

        model.selection = "memos"
        model.selection = "memos"

        XCTAssertEqual(host.selected, ["memos"])
    }

    func testAPathFromTheHostIsAppliedWithoutEchoingBack() {
        let model = model()

        model.pathChanged(tabId: "home", entries: [FakeEntry(uid: 10)])

        XCTAssertEqual(model.path(for: "home").map(\.id), [10])
        XCTAssertEqual(host.reported, [])
    }

    func testANativePopReportsWhatRemains() {
        let model = model()
        model.pathChanged(tabId: "home", entries: [FakeEntry(uid: 10), FakeEntry(uid: 11)])

        model.applyNativePathChange(tabId: "home", newPath: [RouteEntry(entry: FakeEntry(uid: 10))])

        XCTAssertEqual(model.path(for: "home").map(\.id), [10])
        XCTAssertEqual(host.reported, [[10]])
    }

    func testChromeOutlivesAPushedEntryOnlyWhileItIsOnAPath() {
        let model = model()
        model.pathChanged(tabId: "home", entries: [FakeEntry(uid: 10)])
        model.chromeChanged(entryUid: 10, chrome: chrome)
        XCTAssertNotNil(model.chromes[10])

        model.pathChanged(tabId: "home", entries: [])

        XCTAssertNil(model.chromes[10])
    }

    func testARootsChromeSurvivesPathChanges() {
        let model = model()
        model.chromeChanged(entryUid: 1, chrome: chrome)

        model.pathChanged(tabId: "home", entries: [FakeEntry(uid: 10)])
        model.pathChanged(tabId: "home", entries: [])

        XCTAssertNotNil(model.chromes[1])
    }

    func testSelectionFollowsTheHost() {
        let model = model()

        model.tabSelectionRequested(tabId: "memos")

        XCTAssertEqual(model.selection, "memos")
    }

    func testABadgeIsSetAndCleared() {
        let model = model()

        model.tabBadgeChanged(tabId: "memos", badge: "3")
        XCTAssertEqual(model.tabBadges["memos"], "3")

        model.tabBadgeChanged(tabId: "memos", badge: nil)
        XCTAssertNil(model.tabBadges["memos"])
    }
}
