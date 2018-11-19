import Foundation
import Alamofire


/// Account: Remote Endpoints
///
public class AccountRemote: Remote {

    /// Loads the Account Details associated with the Credential's authToken.
    ///
    public func loadAccount(completion: @escaping (Account?, Error?) -> Void) {
        let path = "me"
        let request = DotcomRequest(wordpressApiVersion: .mark1_1, method: .get, path: path)
        let mapper = AccountMapper()

        enqueue(request, mapper: mapper, completion: completion)
    }


    /// Loads the Sites collection associated with the WordPress.com User.
    ///
    public func loadSites(completion: @escaping ([Site]?, Error?) -> Void) {
        let path = "me/sites"
        let parameters = [
            "fields": "ID,name,description,URL,options"
        ]

        let request = DotcomRequest(wordpressApiVersion: .mark1_1, method: .get, path: path, parameters: parameters)
        let mapper = SiteListMapper()

        enqueue(request, mapper: mapper, completion: completion)
    }

    /// Loads Details for Sites collection associated with the WordPress.com user.
    ///
    public func loadSitesDetail(completion: @escaping ([Site]?, Error?) -> Void) {
        let path = "me/sites"
        let parameters = [
            "fields": "ID,name,description,URL,jetpack,plan,options"
        ]

        let request = DotcomRequest(wordpressApiVersion: .mark1_2, method: .get, path: path, parameters: parameters)
        let mapper = SiteListMapper()

        enqueue(request, mapper: mapper, completion: completion)
    }
}
