/// One pushed screen on a `NavigationStack` path. Identity is the entry's uid, so SwiftUI diffing matches the
/// host's stack exactly.
struct RouteEntry: Hashable, Identifiable {
    let id: Int64
    let entry: any SNNEntry

    @MainActor
    init(entry: any SNNEntry) {
        self.id = entry.uid
        self.entry = entry
    }

    static func == (lhs: RouteEntry, rhs: RouteEntry) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
