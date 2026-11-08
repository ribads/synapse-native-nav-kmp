import ObjectiveC
import UIKit
import XCTest
@testable import SynapseNativeNav

/// The Kotlin side binds these names through a hand-mirrored header, so renaming one breaks it at link or run time.
final class ObjectiveCContractTests: XCTestCase {

    private func assertInstances(of type: AnyClass, respondTo selectors: [String]) {
        for selector in selectors {
            XCTAssertNotNil(class_getInstanceMethod(type, NSSelectorFromString(selector)), "\(type) lost \(selector)")
        }
    }

    private func assertRequired(_ selectors: [String], in proto: Protocol) {
        var count: UInt32 = 0
        let methods = protocol_copyMethodDescriptionList(proto, true, true, &count)
        defer { free(methods) }
        let names = Set(UnsafeBufferPointer(start: methods, count: Int(count)).compactMap(\.name).map(NSStringFromSelector))
        XCTAssertEqual(names, Set(selectors))
    }

    func testClassesKeepTheirObjectiveCNames() {
        XCTAssertEqual(NSStringFromClass(SNNShell.self), "SNNShell")
        XCTAssertEqual(NSStringFromClass(SNNTab.self), "SNNTab")
        XCTAssertEqual(NSStringFromClass(SNNChrome.self), "SNNChrome")
        XCTAssertEqual(NSStringFromClass(SNNChromeAction.self), "SNNChromeAction")
        XCTAssertEqual(NSStringFromClass(SNNChromeMenuItem.self), "SNNChromeMenuItem")
    }

    func testTheShellKeepsItsSelectors() {
        XCTAssertNotNil(class_getClassMethod(SNNShell.self, NSSelectorFromString("isSupported")))
        assertInstances(of: SNNShell.self, respondTo: [
            "initWithTabs:",
            "makeViewControllerWithHost:",
            "setPath:forTab:",
            "selectTab:",
            "setBadge:forTab:",
            "setChrome:forEntryUid:",
        ])
    }

    func testValueObjectsKeepTheirInitializers() {
        assertInstances(of: SNNTab.self, respondTo: ["initWithIdentifier:title:sfSymbol:image:root:"])
        assertInstances(of: SNNChrome.self, respondTo: ["initWithTitle:subtitle:titleDisplay:leading:actions:"])
        assertInstances(of: SNNChromeAction.self, respondTo: ["initWithIdentifier:title:sfSymbol:image:role:enabled:menuItems:"])
        assertInstances(of: SNNChromeMenuItem.self, respondTo: ["initWithIdentifier:title:sfSymbol:image:role:enabled:"])
    }

    func testProtocolsKeepTheirRequirements() {
        assertRequired(
            ["uid", "viewController", "setContentInsetsTop:bottom:", "performAction:", "performLeadingAction"],
            in: SNNEntry.self
        )
        assertRequired(["nativeStackChangedForTab:entries:"], in: SNNHost.self)
    }

    func testEnumsKeepTheirRawValues() {
        XCTAssertEqual(SNNChromeTitleDisplay.inline.rawValue, 0)
        XCTAssertEqual(SNNChromeTitleDisplay.large.rawValue, 1)
        XCTAssertEqual(SNNChromeLeading.back.rawValue, 0)
        XCTAssertEqual(SNNChromeLeading.close.rawValue, 1)
        XCTAssertEqual(SNNChromeLeading.hidden.rawValue, 2)
        XCTAssertEqual(SNNChromeRole.standard.rawValue, 0)
        XCTAssertEqual(SNNChromeRole.confirm.rawValue, 1)
        XCTAssertEqual(SNNChromeRole.destructive.rawValue, 2)
    }
}
