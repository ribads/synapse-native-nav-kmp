import SwiftUI
import UIKit

/// Toolbar items for one screen's chrome. Confirm actions take the confirmation placement, which iOS renders
/// prominently. A close affordance replaces the back button, which the caller hides.
@available(iOS 26.0, *)
struct ChromeToolbar: ToolbarContent {
    let chrome: SNNChrome?
    let entry: any SNNEntry

    var body: some ToolbarContent {
        if chrome?.leading == .close {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close) { entry.performLeadingAction() }
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ForEach(actions { $0.role != .confirm }, id: \.identifier) { action in
                ChromeActionView(action: action, entry: entry)
            }
        }
        ToolbarItemGroup(placement: .confirmationAction) {
            ForEach(actions { $0.role == .confirm }, id: \.identifier) { action in
                ChromeActionView(action: action, entry: entry)
            }
        }
    }

    private func actions(where matches: (SNNChromeAction) -> Bool) -> [SNNChromeAction] {
        (chrome?.actions ?? []).filter(matches)
    }
}

@available(iOS 26.0, *)
private struct ChromeActionView: View {
    let action: SNNChromeAction
    let entry: any SNNEntry

    var body: some View {
        if let items = action.menuItems {
            Menu {
                ForEach(items, id: \.identifier) { item in
                    Button(role: buttonRole(item.role)) {
                        entry.performAction(item.identifier)
                    } label: {
                        ChromeLabel(title: item.title, sfSymbol: item.sfSymbol, image: item.image)
                    }
                    .disabled(!item.enabled)
                }
            } label: {
                ChromeLabel(title: action.title, sfSymbol: action.sfSymbol, image: action.image)
            }
            .disabled(!action.enabled)
        } else {
            Button(role: buttonRole(action.role)) {
                entry.performAction(action.identifier)
            } label: {
                ChromeLabel(title: action.title, sfSymbol: action.sfSymbol, image: action.image)
            }
            .disabled(!action.enabled)
        }
    }

    private func buttonRole(_ role: SNNChromeRole) -> ButtonRole? {
        switch role {
        case .destructive: .destructive
        case .confirm: .confirm
        case .standard: nil
        }
    }
}

/// The title always travels with the icon: it is the accessibility label, and what the system shows when it moves
/// an item into a menu. The toolbar decides whether to show it.
@available(iOS 26.0, *)
private struct ChromeLabel: View {
    let title: String
    let sfSymbol: String?
    let image: UIImage?

    var body: some View {
        if let sfSymbol {
            Label(title, systemImage: sfSymbol)
        } else if let image {
            Label { Text(title) } icon: { Image(uiImage: image).renderingMode(.template) }
        } else {
            Text(title)
        }
    }
}
