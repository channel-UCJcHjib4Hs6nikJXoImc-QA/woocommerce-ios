import SwiftUI
import Yosemite

/// Hosting controller wrapper for `CouponDetails`
///
final class CouponDetailsHostingController: UIHostingController<CouponDetails> {

    init(viewModel: CouponDetailsViewModel) {
        super.init(rootView: CouponDetails(viewModel: viewModel))
        // The navigation title is set here instead of the SwiftUI view's `navigationTitle`
        // to avoid the blinking of the title label when pushed from UIKit view.
        title = NSLocalizedString("Coupon", comment: "Title of Coupon Details screen")

        // Set presenting view controller to show the notice presenter here
        rootView.noticePresenter.presentingViewController = self
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct CouponDetails: View {
    @ObservedObject private var viewModel: CouponDetailsViewModel
    @State private var showingActionSheet: Bool = false

    /// The presenter to display notice when the coupon code is copied.
    /// It is kept internal so that the hosting controller can update its presenting controller to itself.
    let noticePresenter: DefaultNoticePresenter

    init(viewModel: CouponDetailsViewModel) {
        self.viewModel = viewModel
        self.noticePresenter = DefaultNoticePresenter()
    }

    private var detailRows: [DetailRow] {
        [
            .init(title: Localization.couponCode, content: viewModel.couponCode, action: {}),
            .init(title: Localization.description, content: viewModel.description, action: {}),
            .init(title: Localization.discount, content: viewModel.amount, action: {}),
            .init(title: Localization.applyTo, content: viewModel.productsAppliedTo, action: {}),
            .init(title: Localization.expiryDate, content: viewModel.expiryDate, action: {})
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Localization.detailSectionTitle)
                        .bold()
                        .padding(Constants.margin)
                        .padding(.horizontal, insets: geometry.safeAreaInsets)
                    ForEach(detailRows) { row in
                        TitleAndValueRow(title: row.title,
                                         value: .content(row.content),
                                         selectable: true,
                                         action: row.action)
                            .padding(.vertical, Constants.verticalSpacing)
                            .padding(.horizontal, insets: geometry.safeAreaInsets)
                        Divider()
                            .padding(.leading, Constants.margin)
                            .padding(.leading, insets: geometry.safeAreaInsets)
                    }
                }
                .background(Color(.listForeground))
            }
            .background(Color(.listBackground))
            .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    showingActionSheet = true
                }, label: {
                    Image(uiImage: .moreImage)
                }).actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(
                        title: Text(Localization.manageCoupon),
                        buttons: [
                            .default(Text(Localization.copyCode), action: {
                                UIPasteboard.general.string = viewModel.couponCode
                                let notice = Notice(title: Localization.couponCopied, feedbackType: .success)
                                noticePresenter.enqueue(notice: notice)
                            }),
                            .default(Text(Localization.shareCoupon), action: {
                                // TODO:
                            })
                        ]
                    )
                }
            }
        }
        .wooNavigationBarStyle()
    }
}

// MARK: - Subtypes
//
private extension CouponDetails {
    enum Constants {
        static let margin: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
    }

    enum Localization {
        static let detailSectionTitle = NSLocalizedString("Coupon Details", comment: "Title of Details section in Coupon Details screen")
        static let couponCode = NSLocalizedString("Coupon Code", comment: "Title of the Coupon Code row in Coupon Details screen")
        static let description = NSLocalizedString("Description", comment: "Title of the Description row in Coupon Details screen")
        static let discount = NSLocalizedString("Discount", comment: "Title of the Discount row in Coupon Details screen")
        static let applyTo = NSLocalizedString("Apply To", comment: "Title of the Apply To row in Coupon Details screen")
        static let expiryDate = NSLocalizedString("Coupon Expiry Date", comment: "Title of the Coupon Expiry Date row in Coupon Details screen")
        static let manageCoupon = NSLocalizedString("Manage Coupon", comment: "Title of the action sheet displayed from the Coupon Details screen")
        static let copyCode = NSLocalizedString("Copy Code", comment: "Action title for copying coupon code from the Coupon Details screen")
        static let couponCopied = NSLocalizedString("Coupon copied", comment: "Notice message displayed when a coupon code is " +
                                                    "copied from the Coupon Details screen")
        static let shareCoupon = NSLocalizedString("Share Coupon", comment: "Action title for sharing coupon from the Coupon Details screen")
    }

    struct DetailRow: Identifiable {
        var id: String { title }

        let title: String
        let content: String
        let action: () -> Void
    }
}

#if DEBUG
struct CouponDetails_Previews: PreviewProvider {
    static var previews: some View {
        CouponDetails(viewModel: CouponDetailsViewModel(coupon: Coupon.sampleCoupon))
    }
}
#endif
