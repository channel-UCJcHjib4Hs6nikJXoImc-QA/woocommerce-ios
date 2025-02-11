import XCTest

@testable import WooCommerce
import Yosemite

/// Unit tests for `ProductFormViewModel`'s `saveProductRemotely`
final class ProductFormViewModel_SaveTests: XCTestCase {
    private var storesManager: MockStoresManager!

    override func setUp() {
        super.setUp()
        storesManager = MockStoresManager(sessionManager: SessionManager.testingInstance)
        ServiceLocator.setStores(storesManager)
    }

    override func tearDown() {
        storesManager = nil
        super.tearDown()
    }

    // MARK: `saveProductRemotely` for adding a product

    func test_adding_a_product_remotely_with_nil_status_uses_the_original_product() throws {
        // Arrange
        let product = Product.fake().copy(statusKey: ProductStatus.published.rawValue)
        let viewModel = createViewModel(product: product, formType: .add)
        storesManager.whenReceivingAction(ofType: ProductAction.self) { action in
            if case let ProductAction.addProduct(product, onCompletion) = action {
                onCompletion(.success(product))
            }
        }

        // Action
        var savedProduct: EditableProductModel?
        waitForExpectation { expectation in
            viewModel.saveProductRemotely(status: nil) { result in
                savedProduct = try? result.get()
                expectation.fulfill()
            }
        }

        // Assert
        XCTAssertEqual(savedProduct, EditableProductModel(product: product))
    }

    func test_adding_a_product_remotely_with_a_given_status_overrides_the_status_of_the_original_product() throws {
        // Arrange
        let product = Product.fake().copy(statusKey: ProductStatus.published.rawValue)
        let viewModel = createViewModel(product: product, formType: .add)
        storesManager.whenReceivingAction(ofType: ProductAction.self) { action in
            if case let ProductAction.addProduct(product, onCompletion) = action {
                onCompletion(.success(product))
            }
        }

        // Action
        var savedProduct: EditableProductModel?
        waitForExpectation { expectation in
            viewModel.saveProductRemotely(status: .pending) { result in
                savedProduct = try? result.get()
                expectation.fulfill()
            }
        }

        // Assert
        XCTAssertEqual(savedProduct, EditableProductModel(product: product.copy(statusKey: ProductStatus.pending.rawValue)))
    }

    func test_adding_a_product_remotely_fires_replaceLocalID_in_productImagesUploader() throws {
        // Given
        let product = Product.fake().copy(statusKey: ProductStatus.published.rawValue)
        let productImagesUploader = MockProductImageUploader()
        let viewModel = createViewModel(product: product, formType: .add, productImagesUploader: productImagesUploader)
        storesManager.whenReceivingAction(ofType: ProductAction.self) { action in
            if case let ProductAction.addProduct(product, onCompletion) = action {
                onCompletion(.success(product))
            }
        }

        // When
        waitForExpectation { expectation in
            viewModel.saveProductRemotely(status: .pending) { result in
                expectation.fulfill()
            }
        }
        // Then
        XCTAssertTrue(productImagesUploader.replaceLocalIDWasCalled)
    }

    func test_adding_a_product_remotely_fires_method_to_save_images_in_background_using_productImagesUploader() throws {
        // Given
        let product = Product.fake().copy(statusKey: ProductStatus.published.rawValue)
        let productImagesUploader = MockProductImageUploader()
        let viewModel = createViewModel(product: product, formType: .add, productImagesUploader: productImagesUploader)
        storesManager.whenReceivingAction(ofType: ProductAction.self) { action in
            if case let ProductAction.addProduct(product, onCompletion) = action {
                onCompletion(.success(product))
            }
        }

        // When
        waitForExpectation { expectation in
            viewModel.saveProductRemotely(status: .pending) { result in
                expectation.fulfill()
            }
        }

        // Then
        XCTAssertTrue(productImagesUploader.saveProductImagesWhenNoneIsPendingUploadAnymoreWasCalled)
    }

    // MARK: `saveProductRemotely` for editing a product

    func test_editing_a_product_remotely_with_nil_status_uses_the_original_product() throws {
        // Arrange
        let product = Product.fake().copy(statusKey: ProductStatus.published.rawValue)
        let viewModel = createViewModel(product: product, formType: .edit)
        storesManager.whenReceivingAction(ofType: ProductAction.self) { action in
            if case let ProductAction.updateProduct(product, onCompletion) = action {
                onCompletion(.success(product))
            }
        }

        // Action
        var savedProduct: EditableProductModel?
        waitForExpectation { expectation in
            viewModel.saveProductRemotely(status: nil) { result in
                savedProduct = try? result.get()
                expectation.fulfill()
            }
        }

        // Assert
        XCTAssertEqual(savedProduct, EditableProductModel(product: product))
    }

    func test_editing_a_product_remotely_with_a_given_status_overrides_the_status_of_the_original_product() throws {
        // Arrange
        let product = Product.fake().copy(statusKey: ProductStatus.published.rawValue)
        let viewModel = createViewModel(product: product, formType: .edit)
        storesManager.whenReceivingAction(ofType: ProductAction.self) { action in
            if case let ProductAction.updateProduct(product, onCompletion) = action {
                onCompletion(.success(product))
            }
        }

        // Action
        var savedProduct: EditableProductModel?
        waitForExpectation { expectation in
            viewModel.saveProductRemotely(status: .pending) { result in
                savedProduct = try? result.get()
                expectation.fulfill()
            }
        }

        // Assert
        XCTAssertEqual(savedProduct, EditableProductModel(product: product.copy(statusKey: ProductStatus.pending.rawValue)))
    }

    func test_editing_a_product_remotely_fires_method_to_save_images_in_background_using_productImagesUploader() throws {
        // Given
        let product = Product.fake().copy(statusKey: ProductStatus.published.rawValue)
        let productImagesUploader = MockProductImageUploader()
        let viewModel = createViewModel(product: product, formType: .edit, productImagesUploader: productImagesUploader)
        storesManager.whenReceivingAction(ofType: ProductAction.self) { action in
            if case let ProductAction.updateProduct(product, onCompletion) = action {
                onCompletion(.success(product))
            }
        }

        // When
        waitForExpectation { expectation in
            viewModel.saveProductRemotely(status: .pending) { result in
                expectation.fulfill()
            }
        }

        // Then
        XCTAssertTrue(productImagesUploader.saveProductImagesWhenNoneIsPendingUploadAnymoreWasCalled)
    }
}

private extension ProductFormViewModel_SaveTests {
    func createViewModel(
        product: Product,
        formType: ProductFormType,
        productImagesUploader: ProductImageUploaderProtocol = ServiceLocator.productImageUploader
    ) -> ProductFormViewModel {
        let model = EditableProductModel(product: product)
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: model)
        return ProductFormViewModel(product: model,
                                    formType: formType,
                                    productImageActionHandler: productImageActionHandler,
                                    productImagesUploader: productImagesUploader)
    }
}
