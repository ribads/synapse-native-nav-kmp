import UIKit

@objc(SNNChromeTitleDisplay)
public enum SNNChromeTitleDisplay: Int, Sendable {
    case inline
    case large
}

/// What the shell renders at the bar's leading edge.
@objc(SNNChromeLeading)
public enum SNNChromeLeading: Int, Sendable {
    /// The system back affordance, shown and handled by the navigation stack.
    case back
    /// A close button in place of the back affordance.
    case close
    /// Nothing: the back affordance is hidden as well.
    case hidden
}

@objc(SNNChromeRole)
public enum SNNChromeRole: Int, Sendable {
    case standard
    case confirm
    case destructive
}

/// One top-level tab, with the screen at its base.
@objc(SNNTab)
public final class SNNTab: NSObject {
    let identifier: String
    let title: String
    let sfSymbol: String?
    let image: UIImage?
    let root: any SNNEntry

    @objc(initWithIdentifier:title:sfSymbol:image:root:)
    public init(identifier: String, title: String, sfSymbol: String?, image: UIImage?, root: any SNNEntry) {
        self.identifier = identifier
        self.title = title
        self.sfSymbol = sfSymbol
        self.image = image
        self.root = root
    }
}

/// A screen's navigation bar at one instant.
@objc(SNNChrome)
public final class SNNChrome: NSObject {
    let title: String?
    let subtitle: String?
    let titleDisplay: SNNChromeTitleDisplay
    let leading: SNNChromeLeading
    let actions: [SNNChromeAction]

    @objc(initWithTitle:subtitle:titleDisplay:leading:actions:)
    public init(
        title: String?,
        subtitle: String?,
        titleDisplay: SNNChromeTitleDisplay,
        leading: SNNChromeLeading,
        actions: [SNNChromeAction]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.titleDisplay = titleDisplay
        self.leading = leading
        self.actions = actions
    }
}

/// One toolbar action: a `Menu` when it has menu items, otherwise a `Button`.
@objc(SNNChromeAction)
public final class SNNChromeAction: NSObject {
    let identifier: String
    let title: String
    let sfSymbol: String?
    let image: UIImage?
    let role: SNNChromeRole
    let enabled: Bool
    let menuItems: [SNNChromeMenuItem]?

    @objc(initWithIdentifier:title:sfSymbol:image:role:enabled:menuItems:)
    public init(
        identifier: String,
        title: String,
        sfSymbol: String?,
        image: UIImage?,
        role: SNNChromeRole,
        enabled: Bool,
        menuItems: [SNNChromeMenuItem]?
    ) {
        self.identifier = identifier
        self.title = title
        self.sfSymbol = sfSymbol
        self.image = image
        self.role = role
        self.enabled = enabled
        self.menuItems = menuItems
    }
}

@objc(SNNChromeMenuItem)
public final class SNNChromeMenuItem: NSObject {
    let identifier: String
    let title: String
    let sfSymbol: String?
    let image: UIImage?
    let role: SNNChromeRole
    let enabled: Bool

    @objc(initWithIdentifier:title:sfSymbol:image:role:enabled:)
    public init(
        identifier: String,
        title: String,
        sfSymbol: String?,
        image: UIImage?,
        role: SNNChromeRole,
        enabled: Bool
    ) {
        self.identifier = identifier
        self.title = title
        self.sfSymbol = sfSymbol
        self.image = image
        self.role = role
        self.enabled = enabled
    }
}
