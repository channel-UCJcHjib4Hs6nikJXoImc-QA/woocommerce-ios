import Foundation
import Yosemite
import Combine

final class SetUpTapToPayCompleteViewModel: PaymentSettingsFlowPresentedViewModel, ObservableObject {
    private(set) var shouldShow: CardReaderSettingsTriState = .isUnknown
    var didChangeShouldShow: ((CardReaderSettingsTriState) -> Void)?
    var didUpdate: (() -> Void)?

    private var doneWasTapped: Bool = false

    private(set) var connectedReader: CardReaderSettingsTriState = .isUnknown

    private let connectionAnalyticsTracker: CardReaderConnectionAnalyticsTracker
    private let stores: StoresManager

    private var subscriptions = Set<AnyCancellable>()

    init(didChangeShouldShow: ((CardReaderSettingsTriState) -> Void)?,
         connectionAnalyticsTracker: CardReaderConnectionAnalyticsTracker,
         stores: StoresManager = ServiceLocator.stores) {
        self.didChangeShouldShow = didChangeShouldShow
        self.connectionAnalyticsTracker = connectionAnalyticsTracker
        self.stores = stores

        beginConnectedReaderObservation()
    }

    /// Set up to observe readers connecting / disconnecting
    ///
    private func beginConnectedReaderObservation() {
        // This completion should be called repeatedly as the list of connected readers changes
        let connectedAction = CardPresentPaymentAction.observeConnectedReaders() { [weak self] readers in
            guard let self = self else {
                return
            }
            self.connectedReader = readers.isNotEmpty ? .isTrue : .isFalse
            self.reevaluateShouldShow()
        }
        stores.dispatch(connectedAction)
    }

    /// Updates whether the view this viewModel is associated with should be shown or not
    /// Notifies the viewModel owner if a change occurs via didChangeShouldShow
    ///
    private func reevaluateShouldShow() {
        let newShouldShow: CardReaderSettingsTriState
        switch (doneWasTapped, connectedReader) {
        case (true, _):
            newShouldShow = .isFalse
        case (false, _):
            newShouldShow = connectedReader
        }

        let didChange = newShouldShow != shouldShow

        shouldShow = newShouldShow

        if didChange {
            didChangeShouldShow?(shouldShow)
        }
    }

    func doneTapped() {
        doneWasTapped = true
        reevaluateShouldShow()
    }

    deinit {
        subscriptions.removeAll()
    }
}
