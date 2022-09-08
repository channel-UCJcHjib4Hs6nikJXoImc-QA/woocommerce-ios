import WidgetKit
import KeychainAccess

/// Type that represents the Widget information
///
struct StoreInfoEntry: TimelineEntry {
    /// Date to request new info
    ///
    var date: Date

    /// Eg: Today, Weekly, Monthly, Yearly
    ///
    var range: String

    /// Store name
    ///
    var name: String

    /// Revenue at the range (eg: today)
    ///
    var revenue: String

    /// Visitors count at the range (eg: today)
    ///
    var visitors: String

    /// Order count at the range (eg: today)
    ///
    var orders: String

    /// Conversion at the range (eg: today)
    ///
    var conversion: String
}

/// Type that provides data entries to the widget system.
///
final class StoreInfoProvider: TimelineProvider {

    /// Holds a reference to the service while a network request is being performed.
    ///
    private var networkService: StoreInfoDataService?

    /// Redacted entry with sample data.
    ///
    func placeholder(in context: Context) -> StoreInfoEntry {
        let dependencies = Self.fetchDependencies()
        return StoreInfoEntry(date: Date(),
                              range: "Today",
                              name: dependencies?.storeName ?? Localization.myShop,
                              revenue: "$132.234",
                              visitors: "67",
                              orders: "23",
                              conversion: "34%")
    }

    /// Quick Snapshot. Required when previewing the widget.
    ///
    func getSnapshot(in context: Context, completion: @escaping (StoreInfoEntry) -> Void) {
        completion(placeholder(in: context))
    }

    /// Real data widget.
    /// TODO: Update with real data.
    ///
    func getTimeline(in context: Context, completion: @escaping (Timeline<StoreInfoEntry>) -> Void) {
        // TODO: Temp store name to check dependency status while we fetch real data.
        let dependencies = Self.fetchDependencies()

        networkService = StoreInfoDataService(authToken: dependencies?.authToken ?? "")
        networkService?.fetchData(for: dependencies?.storeID ?? 0, completion: { result in
            // No Op
        })

        let authStatus = dependencies?.authToken != nil ? "Authenticated" : "Non Authenticated"
        let storeName = dependencies?.storeName ?? "Undefined Shop"
        let entry = StoreInfoEntry(date: Date(),
                                   range: "Today",
                                   name: "\(authStatus) - \(storeName)",
                                   revenue: "$132.234",
                                   visitors: "67",
                                   orders: "23",
                                   conversion: "37%")
        let timeline = Timeline<StoreInfoEntry>(entries: [entry], policy: .never)
        completion(timeline)
    }
}

private extension StoreInfoProvider {

    /// Dependencies needed by the `StoreInfoProvider`
    ///
    struct Dependencies {
        let authToken: String
        let storeID: Int64
        let storeName: String
    }

    /// Fetches the required dependencies from the keychain and the shared users default.
    ///
    static func fetchDependencies() -> Dependencies? {
        let keychain = Keychain(service: WooConstants.keychainServiceName)
        guard let authToken = keychain[WooConstants.authToken],
              let storeID = UserDefaults.group?[.defaultStoreID] as? Int64,
              let storeName = UserDefaults.group?[.defaultStoreName] as? String else {
            return nil
        }
        return Dependencies(authToken: authToken, storeID: storeID, storeName: storeName)
    }
}

private extension StoreInfoProvider {
    enum Localization {
        static let myShop = NSLocalizedString("My Shop", comment: "Generic store name for the store info widget preview")
    }
}
