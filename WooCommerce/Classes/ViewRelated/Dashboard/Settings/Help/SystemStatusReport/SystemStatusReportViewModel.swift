import Foundation
import Yosemite

/// View model for `SystemStatusReportView`
///
final class SystemStatusReportViewModel: ObservableObject {
    /// ID of the site to fetch system status report for
    ///
    private let siteID: Int64

    /// Stores to handle fetching system status
    ///
    private let stores: StoresManager

    /// Formatted system status report to be displayed on-screen
    ///
    @Published private(set) var statusReport: String = ""

    /// Whether fetching system status report failed
    ///
    @Published var errorFetchingReport: Bool = false

    init(siteID: Int64, stores: StoresManager = ServiceLocator.stores) {
        self.siteID = siteID
        self.stores = stores
    }

    func fetchReport() {
        errorFetchingReport = false
        let action = SystemStatusAction.fetchSystemStatusReport(siteID: siteID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let status):
                self.statusReport = self.formatReport(with: status)
            case .failure:
                self.errorFetchingReport = true
            }
        }
        stores.dispatch(action)
    }
}

private extension SystemStatusReportViewModel {
    /// Format system status to match with Core's report.
    /// Not localizing content and keep English by default.
    ///
    func formatReport(with systemStatus: SystemStatus) -> String {
        var lines = ["### System Status Report generated via the WooCommerce iOS app ###"]

        // Environment
        if let environment = systemStatus.environment {
            lines.append(contentsOf: [
                "\n",
                "### WordPress Environment ###",
                "\n",
                "WordPress addresss (URL): \(environment.homeURL)",
                "Site address (URL): \(environment.siteURL)",
                "WC Version: \(environment.version)",
                "Log Directory Writable: \(environment.logDirectoryWritable.stringRepresentable)",
                "WP Version: \(environment.wpVersion)",
                "WP Multisite: \(environment.wpMultisite)",
                "WP Memory Limit: \(environment.wpMemoryLimit.byteCountRepresentable)",
                "WP Debug Mode: \(environment.wpDebugMode.stringRepresentable)",
                "WP Cron: \(environment.wpCron.stringRepresentable)",
                "Language: \(environment.language)",
                "External object cache: \((environment.externalObjectCache ?? false).stringRepresentable)",
                "\n",
                "### Server Environment ###",
                "\n",
                "Server Info: \(environment.serverInfo)",
                "PHP Version: \(environment.phpVersion)",
                "PHP Post Max Size: \(environment.phpPostMaxSize.byteCountRepresentable)",
                "PHP Time Limit: \(environment.phpMaxExecutionTime)",
                "PHP Max Input Vars: \(environment.phpMaxInputVars)",
                "cURL Version: \(environment.curlVersion)",
                "\n",
                "SUHOSIN Installed: \(environment.suhosinInstalled.stringRepresentable)",
                "MySQL Version: \(environment.mysqlVersion)",
                "Max Upload Size: \(environment.maxUploadSize.byteCountRepresentable)",
                "Default Timezone is UTC: \((environment.defaultTimezone == "UTC").stringRepresentable)",
                "fsockopen/cURL: \(environment.fsockopenOrCurlEnabled.stringRepresentable)",
                "SoapClient: \(environment.soapClientEnabled.stringRepresentable)",
                "DOMDocument: \(environment.domDocumentEnabled.stringRepresentable)",
                "GZip: \(environment.gzipEnabled.stringRepresentable)",
                "Multibyte String: \(environment.mbstringEnabled.stringRepresentable)",
                "Remote Post: \(environment.remotePostSuccessful.stringRepresentable)",
                "Remote Get: \(environment.remoteGetSuccessful.stringRepresentable)"
            ])
        }

        // Database
        if let database = systemStatus.database {
            lines.append(contentsOf: [
                "\n",
                "### Database ###",
                "\n",
                "WC Database Version: \(database.wcDatabaseVersion)",
                String(format: "Total Database Size: %.2fMB", database.databaseSize.data + database.databaseSize.index),
                String(format: "Database Data Size: %.2fMB", database.databaseSize.data),
                String(format: "Database Index Size: %.2fMB", database.databaseSize.index)
            ])

            for (tableName, content) in database.databaseTables.woocommerce {
                lines.append("\(tableName): Data: \(content.data)MB + Index: \(content.index)MB + Engine \(content.engine)")
            }

            for (tableName, content) in database.databaseTables.other {
                lines.append("\(tableName): Data: \(content.data)MB + Index: \(content.index)MB + Engine \(content.engine)")
            }
        }

        return lines.joined(separator: "\n")
    }
}
