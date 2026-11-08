import SwiftUI

@available(iOS 26.0, *)
struct NativeShellView: View {
    let model: NavigationModel

    var body: some View {
        @Bindable var model = model
        TabView(selection: $model.selection) {
            ForEach(model.tabs, id: \.identifier) { tab in
                Tab(value: tab.identifier) {
                    TabStackView(model: model, tab: tab)
                } label: {
                    Label {
                        Text(tab.title)
                    } icon: {
                        tabIcon(tab)
                    }
                }
                .badge(model.tabBadges[tab.identifier].map(Text.init))
            }
        }
        .tabBarMinimizeBehavior(.automatic)
    }

    @ViewBuilder
    private func tabIcon(_ tab: SNNTab) -> some View {
        if let sfSymbol = tab.sfSymbol {
            Image(systemName: sfSymbol)
        } else if let image = tab.image {
            Image(uiImage: image).renderingMode(.template)
        }
    }
}
