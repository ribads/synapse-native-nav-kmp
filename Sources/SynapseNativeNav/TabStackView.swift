import SwiftUI

/// One tab's `NavigationStack`. A root without chrome hides the navigation bar, as the screen draws its own header,
/// but still sets `navigationTitle`, which iOS 26 reads to label the floating tab bar.
@available(iOS 26.0, *)
struct TabStackView: View {
    let model: NavigationModel
    let tab: SNNTab

    var body: some View {
        NavigationStack(path: pathBinding) {
            hostedScreen(tab.root, isRoot: true)
                .navigationDestination(for: RouteEntry.self) { route in
                    hostedScreen(route.entry, isRoot: false)
                }
        }
    }

    private func hostedScreen(_ entry: any SNNEntry, isRoot: Bool) -> some View {
        let chrome = model.chromes[entry.uid]
        let title: String = chrome?.title ?? (isRoot ? tab.title : "")
        let subtitle: String = chrome?.subtitle ?? ""
        let barVisibility: Visibility = isRoot && chrome == nil ? .hidden : .automatic

        return insetReportingScreen(entry)
            .navigationTitle(title)
            .navigationSubtitle(subtitle)
            .toolbarTitleDisplayMode(titleDisplayMode(chrome, isRoot: isRoot))
            .toolbar(barVisibility, for: .navigationBar)
            .navigationBarBackButtonHidden(hidesSystemBack(chrome))
            .toolbar {
                ChromeToolbar(chrome: chrome, entry: entry)
            }
    }

    private func titleDisplayMode(_ chrome: SNNChrome?, isRoot: Bool) -> ToolbarTitleDisplayMode {
        if chrome?.titleDisplay == .large { return .large }
        return isRoot ? .automatic : .inline
    }

    private func hidesSystemBack(_ chrome: SNNChrome?) -> Bool {
        guard let chrome else { return false }
        return chrome.leading != .back
    }

    // Only the hosted view ignores the safe area, so the proxy still reports how far the native bars overlap it.
    private func insetReportingScreen(_ entry: any SNNEntry) -> some View {
        GeometryReader { proxy in
            ComposeScreenView(viewController: entry.viewController())
                .ignoresSafeArea()
                .onAppear { report(proxy.safeAreaInsets, for: entry) }
                .onChange(of: proxy.safeAreaInsets) { _, insets in
                    report(insets, for: entry)
                }
        }
    }

    private func report(_ insets: EdgeInsets, for entry: any SNNEntry) {
        entry.setContentInsets(top: insets.top, bottom: insets.bottom)
    }

    private var pathBinding: Binding<[RouteEntry]> {
        Binding(
            get: { model.path(for: tab.identifier) },
            set: { newPath in
                model.applyNativePathChange(tabId: tab.identifier, newPath: newPath)
            }
        )
    }
}
