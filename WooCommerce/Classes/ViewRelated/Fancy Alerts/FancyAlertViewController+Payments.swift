import Foundation
import WordPressUI

public extension FancyAlertViewController {

    /// Create the fancy alert controller for the WC 3.5 upgrade alert that appears after the login flow is completed.
    ///
    /// - Returns: FancyAlertViewController of the alert
    ///
    static func makeCollectPaymentAlert(name: String, amount: String, image: UIImage) -> FancyAlertViewController {

        //let dismissButton = makeDismissButtonConfig()
        //let moreInfoButton = makeMoreInfoButtonConfig()
        let config = configuration(title: name, bodyText: amount, image: image)

        let controller = FancyAlertViewController.controllerWithConfiguration(configuration: config)
        return controller
    }

    static func configuration(title: String, bodyText: String, image: UIImage) -> FancyAlertViewController.Config {
        FancyAlertViewController.Config(titleText: title,
                                        bodyText: bodyText,
                                        headerImage: image,
                                        dividerPosition: .top,
                                        defaultButton: nil,
                                        cancelButton: nil,
                                        moreInfoButton: nil,
                                        dismissAction: {})
    }

    static func configurationForSuccess(title: String, bodyText: String, image: UIImage, printAction: @escaping () -> Void) -> FancyAlertViewController.Config {
        FancyAlertViewController.Config(titleText: title,
                                        bodyText: bodyText,
                                        headerImage: image,
                                        dividerPosition: .top,
                                        defaultButton: makePrintButon(printAction: printAction),
                                        cancelButton: nil,
                                        moreInfoButton: nil,
                                        dismissAction: {})
    }

    private static func makePrintButon(printAction: @escaping () -> Void) -> FancyAlertViewController.Config.ButtonConfig {
        return FancyAlertViewController.Config.ButtonConfig("Print") { controller, _ in
            printAction()
            controller.dismiss(animated: true)
        }
    }
}
