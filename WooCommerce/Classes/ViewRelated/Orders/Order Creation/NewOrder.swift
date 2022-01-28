import SwiftUI
import Combine

/// Hosting controller that wraps an `NewOrder` view.
///
final class NewOrderHostingController: UIHostingController<NewOrder> {
    private let noticePresenter: NoticePresenter

    /// References to keep the Combine subscriptions alive within the lifecycle of the object.
    ///
    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: NewOrderViewModel, noticePresenter: NoticePresenter = ServiceLocator.noticePresenter) {
        self.noticePresenter = noticePresenter
        super.init(rootView: NewOrder(viewModel: viewModel))

        observeNoticeIntent()
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Observe the present notice intent and set it back after presented.
    ///
    private func observeNoticeIntent() {
        rootView.viewModel.$presentNotice
            .compactMap { $0 }
            .sink { [weak self] notice in
                switch notice {
                case .error:
                    self?.noticePresenter.enqueue(notice: .init(title: NewOrder.Localization.errorMessage, feedbackType: .error))
                }

                // Nullify the presentation intent.
                self?.rootView.viewModel.presentNotice = nil
            }
            .store(in: &subscriptions)
    }
}

/// View to create a new manual order
///
struct NewOrder: View {
    @ObservedObject var viewModel: NewOrderViewModel

    /// Fix for breaking navbar button
    @State private var navigationButtonID = UUID()

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    VStack(spacing: Layout.noSpacing) {
                        OrderStatusSection(viewModel: viewModel)

                        Spacer(minLength: Layout.sectionSpacing)

                        ProductsSection(geometry: geometry, scroll: scroll, viewModel: viewModel, navigationButtonID: $navigationButtonID)

                        Spacer(minLength: Layout.sectionSpacing)

                        if viewModel.shouldShowPaymentSection {
                            OrderPaymentSection(viewModel: viewModel.paymentDataViewModel)

                            Spacer(minLength: Layout.sectionSpacing)
                        }

                        OrderCustomerSection(viewModel: viewModel)
                    }
                }
                .background(Color(.listBackground).ignoresSafeArea())
                .ignoresSafeArea(.container, edges: [.horizontal])
            }
        }
        .navigationTitle(Localization.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                switch viewModel.navigationTrailingItem {
                case .none:
                    EmptyView()
                case .create:
                    Button(Localization.createButton) {
                        viewModel.createOrder()
                    }.id(navigationButtonID)
                case .loading:
                    ProgressView()
                }
            }
        }
        .wooNavigationBarStyle()
    }
}

// MARK: Order Sections
/// Represents the Products section
///
private struct ProductsSection: View {
    let geometry: GeometryProxy
    let scroll: ScrollViewProxy

    /// View model to drive the view content
    @ObservedObject var viewModel: NewOrderViewModel

    /// Fix for breaking navbar button
    @Binding var navigationButtonID: UUID

    /// Defines whether `AddProduct` modal is presented.
    ///
    @State private var showAddProduct: Bool = false

    /// ID for Add Product button
    ///
    @Namespace var addProductButton

    var body: some View {
        Group {
            Divider()

            VStack(alignment: .leading, spacing: NewOrder.Layout.verticalSpacing) {
                Text(NewOrder.Localization.products)
                    .headlineStyle()

                ForEach(viewModel.productRows) { productRow in
                    ProductRow(viewModel: productRow)
                        .onTapGesture {
                            viewModel.selectOrderItem(productRow.id)
                        }
                        .sheet(item: $viewModel.selectedOrderItem) { item in
                            createProductInOrderView(for: item)
                        }

                    Divider()
                }

                Button(NewOrder.Localization.addProduct) {
                    showAddProduct.toggle()
                }
                .id(addProductButton)
                .buttonStyle(PlusButtonStyle())
                .sheet(isPresented: $showAddProduct, onDismiss: {
                    scroll.scrollTo(addProductButton)
                }, content: {
                    AddProductToOrder(isPresented: $showAddProduct, viewModel: viewModel.addProductViewModel)
                        .onDisappear {
                            navigationButtonID = UUID()
                        }
                })
            }
            .padding(.horizontal, insets: geometry.safeAreaInsets)
            .padding()
            .background(Color(.listForeground))

            Divider()
        }
    }

    @ViewBuilder private func createProductInOrderView(for item: NewOrderViewModel.NewOrderItem) -> some View {
        if let productRowViewModel = viewModel.createProductRowViewModel(for: item, canChangeQuantity: false) {
            let productInOrderViewModel = ProductInOrderViewModel(productRowViewModel: productRowViewModel) {
                viewModel.removeItemFromOrder(item)
            }
            ProductInOrder(viewModel: productInOrderViewModel)
        }
        EmptyView()
    }
}

// MARK: Constants
private extension NewOrder {
    enum Layout {
        static let sectionSpacing: CGFloat = 16.0
        static let verticalSpacing: CGFloat = 22.0
        static let noSpacing: CGFloat = 0.0
    }

    enum Localization {
        static let title = NSLocalizedString("New Order", comment: "Title for the order creation screen")
        static let createButton = NSLocalizedString("Create", comment: "Button to create an order on the New Order screen")
        static let errorMessage = NSLocalizedString("Unable to create new order", comment: "Notice displayed when order creation fails")
        static let products = NSLocalizedString("Products", comment: "Title text of the section that shows the Products when creating a new order")
        static let addProduct = NSLocalizedString("Add product", comment: "Title text of the button that adds a product when creating a new order")
    }
}

struct NewOrder_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = NewOrderViewModel(siteID: 123)

        NavigationView {
            NewOrder(viewModel: viewModel)
        }

        NavigationView {
            NewOrder(viewModel: viewModel)
        }
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        .previewDisplayName("Accessibility")

        NavigationView {
            NewOrder(viewModel: viewModel)
        }
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark")

        NavigationView {
            NewOrder(viewModel: viewModel)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .previewDisplayName("Right to left")
    }
}
