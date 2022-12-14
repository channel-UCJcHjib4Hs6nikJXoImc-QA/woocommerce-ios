import SwiftUI

/// Reusable Time Range card made for the Analytics Hub.
///
struct AnalyticsTimeRangeCard: View {

    let timeRangeTitle: String
    let currentRangeDescription: String
    let previousRangeDescription: String
    @Binding var selectionType: AnalyticsHubTimeRangeSelection.SelectionType

    /// Determines if the time range selection should be shown.
    ///
    @State private var showTimeRangeSelectionView: Bool = false

    /// Determines if the custom range selection should be shown.
    ///
    @State private var showCustomRangeSelectionView: Bool = false

    private let usageTracksEventEmitter: StoreStatsUsageTracksEventEmitter

    init(viewModel: AnalyticsTimeRangeCardViewModel, selectionType: Binding<AnalyticsHubTimeRangeSelection.SelectionType>) {
        self.timeRangeTitle = viewModel.selectedRangeTitle
        self.currentRangeDescription = viewModel.currentRangeSubtitle
        self.previousRangeDescription = viewModel.previousRangeSubtitle
        self.usageTracksEventEmitter = viewModel.usageTracksEventEmitter
        self._selectionType = selectionType
    }

    var body: some View {
        createTimeRangeContent()
            .sheet(isPresented: $showTimeRangeSelectionView) {
                SelectionList(title: Localization.timeRangeSelectionTitle,
                              items: Range.allCases,
                              contentKeyPath: \.description,
                              selected: internalSelectionBinding()) { selection in
                    usageTracksEventEmitter.interacted()
                    ServiceLocator.analytics.track(event: .AnalyticsHub.dateRangeOptionSelected(selection.tracksIdentifier))
                }
                .sheet(isPresented: $showCustomRangeSelectionView) {
                    // TODO: Pass real dates here
                    RangedDatePicker() { start, end in
                        showTimeRangeSelectionView = false // Dismiss the initial sheet for a smooth transition
                        self.selectionType = .custom(start: start, end: end)
                    }
                }
            }
    }

    private func createTimeRangeContent() -> some View {
        VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
            Button(action: {
                usageTracksEventEmitter.interacted()
                ServiceLocator.analytics.track(event: .AnalyticsHub.dateRangeButtonTapped())
                showTimeRangeSelectionView.toggle()
            }, label: {
                HStack {
                    Image(uiImage: .calendar)
                        .padding()
                        .foregroundColor(Color(.text))
                        .background(Circle().foregroundColor(Color(.systemGray6)))

                    VStack(alignment: .leading, spacing: .zero) {
                        Text(timeRangeTitle)
                            .foregroundColor(Color(.text))
                            .subheadlineStyle()

                        Text(currentRangeDescription)
                            .foregroundColor(Color(.text))
                            .bold()
                    }
                    .padding(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(uiImage: .chevronDownImage)
                        .padding()
                        .foregroundColor(Color(.text))
                        .frame(alignment: .trailing)
                }
            })
            .buttonStyle(.borderless)
            .padding(.leading)
            .contentShape(Rectangle())

            Divider()

            BoldableTextView(Localization.comparisonHeaderTextWith(previousRangeDescription))
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .calloutStyle()
        }
        .padding([.top, .bottom])
        .frame(maxWidth: .infinity)
    }

    /// Tracks the range selection internally to determine if the custom range selection should be presented or not.
    /// If custom range selection is not needed, the internal selection is forwarded to `selectionType`.
    ///
    private func internalSelectionBinding() -> Binding<Range> {
        .init(
            get: {
                return selectionType.asTimeCardRange
            },
            set: { newValue in
                switch newValue {
                    // If we get a `custom` case it is because we need to present the custom range selection
                case .custom:
                    showCustomRangeSelectionView = true
                default:
                    // Any other selection should be forwarded to our parent binding.
                    selectionType = newValue.asAnalyticsHubRange
                }
            }
        )
    }
}

// MARK: Constants
private extension AnalyticsTimeRangeCard {
    enum Layout {
        static let verticalSpacing: CGFloat = 16
    }

    enum Localization {
        static let timeRangeSelectionTitle = NSLocalizedString(
            "Date Range",
            comment: "Title describing the possible date range selections of the Analytics Hub"
        )
        static let previousRangeComparisonContent = NSLocalizedString(
            "Compared to **%1$@**",
            comment: "Subtitle describing the previous analytics period under comparison. E.g. Compared to Oct 1 - 22, 2022"
        )

        static func comparisonHeaderTextWith(_ rangeDescription: String) -> String {
            return String.localizedStringWithFormat(Localization.previousRangeComparisonContent, rangeDescription)
        }
    }
}

// MARK: Previews
struct TimeRangeCard_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AnalyticsTimeRangeCardViewModel(selectedRangeTitle: "Month to Date",
                                                        currentRangeSubtitle: "Nov 1 - 23, 2022",
                                                        previousRangeSubtitle: "Oct 1 - 23, 2022",
                                                        usageTracksEventEmitter: StoreStatsUsageTracksEventEmitter())
        AnalyticsTimeRangeCard(viewModel: viewModel, selectionType: .constant(.monthToDate))
    }
}


extension AnalyticsTimeRangeCard {
    enum Range: CaseIterable {
        case custom
        case today
        case yesterday
        case lastWeek
        case lastMonth
        case lastQuarter
        case lastYear
        case weekToDate
        case monthToDate
        case quarterToDate
        case yearToDate

        /// Wee need to provide a custom `allCases` in order to evict `.custom` while the feature flag is active.
        /// We should delete this once the feature flag has been removed.
        ///
        static var allCases: [Range] {
            [
                ServiceLocator.featureFlagService.isFeatureFlagEnabled(.analyticsHub) ? .custom : nil,
                .today,
                .yesterday,
                .lastWeek,
                .lastMonth,
                .lastQuarter,
                .lastYear,
                .weekToDate,
                .monthToDate,
                .quarterToDate,
                yearToDate
            ].compactMap { $0 }
        }
    }
}
