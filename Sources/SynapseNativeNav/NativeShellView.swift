import SwiftUI

@available(iOS 26.0, *)
struct NativeShellView: View {
    let model: NavigationModel

    var body: some View {
        TabView(selection: Binding(get: { model.selection }, set: { model.choose($0) })) {
            ForEach(model.items, id: \.identifier) { item in
                Tab(value: item.identifier) {
                    tabContent(item)
                } label: {
                    Label {
                        Text(item.title)
                    } icon: {
                        tabIcon(item)
                    }
                }
                .badge(model.tabBadges[item.identifier].map(Text.init))
            }
        }
        .tabBarMinimizeBehavior(.automatic)
    }

    // An action never becomes the selection, so it has no content to show.
    @ViewBuilder
    private func tabContent(_ item: SNNTabItem) -> some View {
        if let tab = item as? SNNTab {
            TabStackView(model: model, tab: tab)
        }
    }

    @ViewBuilder
    private func tabIcon(_ item: SNNTabItem) -> some View {
        if let sfSymbol = item.sfSymbol {
            Image(systemName: sfSymbol)
        } else if let image = item.image {
            Image(uiImage: image).renderingMode(.template)
        }
    }
}
