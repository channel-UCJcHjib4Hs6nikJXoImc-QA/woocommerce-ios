import Foundation
import Codegen

/// Represents customs info for a shipping label package
///
public struct ShippingLabelCustomsForm: Equatable, GeneratedFakeable {
    /// Type of contents to declare with customs.
    public let contentsType: ContentsType

    /// Explanation for contents if of type other, empty otherwise.
    public let contentExplanation: String

    /// Restriction type of contents.
    public let restrictionType: RestrictionType

    /// Details about restriction if of type other, empty otherwise.
    public let restrictionComments: String

    /// Option if delivery fails.
    public let nonDeliveryOption: NonDeliveryOption

    /// Internal Transaction Number, empty if not applicable.
    public let itn: String

    /// Items in the package to declare.
    public let items: [Item]

    public init(contentsType: ShippingLabelCustomsForm.ContentsType,
                contentExplanation: String,
                restrictionType: ShippingLabelCustomsForm.RestrictionType,
                restrictionComments: String,
                nonDeliveryOption: ShippingLabelCustomsForm.NonDeliveryOption,
                itn: String,
                items: [ShippingLabelCustomsForm.Item]) {
        self.contentsType = contentsType
        self.contentExplanation = contentExplanation
        self.restrictionType = restrictionType
        self.restrictionComments = restrictionComments
        self.nonDeliveryOption = nonDeliveryOption
        self.itn = itn
        self.items = items
    }
}

// MARK: - Subtypes
//
public extension ShippingLabelCustomsForm {
    /// Types of contents to declare with customs.
    ///
    enum ContentsType: String, Codable {
        case merchandise
        case documents
        case gift
        case sample
        case other
    }

    /// Types of restriction of contents to declare with customs.
    ///
    enum RestrictionType: String, Codable {
        case none
        case quarantine
        case sanitaryOrPhytosanitaryInspection = "sanitary_phytosanitary_inspection"
        case other
    }

    /// Options if delivery fails.
    ///
    enum NonDeliveryOption: String, Codable {
        case `return`
        case abandon
    }

    /// Information about a item to declare with customs.
    ///
    struct Item: Codable, Equatable, GeneratedFakeable {
        /// Description of item.
        public let description: String

        /// Quantity of item
        public let quantity: Int

        /// Price of item per unit.
        public let value: Double

        /// Weight of item per unit.
        public let weight: Double

        /// HS tariff number, empty if N/A.
        public let hsTariffNumber: String

        /// Origin country code of item.
        public let originCountry: String

        /// Product ID of item.
        public let productID: Int64

        public init(description: String, quantity: Int, value: Double, weight: Double, hsTariffNumber: String, originCountry: String, productID: Int64) {
            self.description = description
            self.quantity = quantity
            self.value = value
            self.weight = weight
            self.hsTariffNumber = hsTariffNumber
            self.originCountry = originCountry
            self.productID = productID
        }
    }
}

// MARK: - Codable
//
extension ShippingLabelCustomsForm.Item {
    private enum CodingKeys: String, CodingKey {
        case description
        case quantity
        case value
        case weight
        case hsTariffNumber = "hs_tariff_number"
        case originCountry = "origin_country"
        case productID = "product_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let description = try container.decode(String.self, forKey: .description)
        let quantity = try container.decode(Int.self, forKey: .quantity)
        let value = try container.decode(Double.self, forKey: .value)
        let weight = try container.decode(Double.self, forKey: .weight)
        let hsTariffNumber = (try? container.decode(String.self, forKey: .hsTariffNumber)) ?? ""
        let originCountry = try container.decode(String.self, forKey: .originCountry)
        let productID = try container.decode(Int64.self, forKey: .productID)

        self.init(description: description,
                  quantity: quantity,
                  value: value,
                  weight: weight,
                  hsTariffNumber: hsTariffNumber,
                  originCountry: originCountry,
                  productID: productID)
    }
}
