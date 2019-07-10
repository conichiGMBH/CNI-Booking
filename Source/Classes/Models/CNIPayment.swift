//
//  CNIPayment.swift
//  CNI-Itineraries
//
//  Created by David Henner on 03.07.19.
//  Copyright © 2019 conichi. All rights reserved.
//

import Foundation

public class CNIPayment: CNIObject, CNIModelDelegate {
    public let tripCosts: CNITripCosts?
    public let cancellation: CNICancellation?
    public let paymentMethod: String?

    public init(tripCosts: CNITripCosts?, cancellation: CNICancellation?, paymentMethod: String?) {
        self.tripCosts = tripCosts
        self.cancellation = cancellation
        self.paymentMethod = paymentMethod
    }

    public func deserialize() -> [String : Any] {
        var dict = [String: Any]()

        dict["trip_costs"] = tripCosts?.deserialize()
        dict["cancellation"] = cancellation?.deserialize()
        dict["payment_method"] = paymentMethod

        return dict
    }
}

public extension CNIPayment {
    class CNITripCosts: CNIObject, CNIModelDelegate {
        public let grossAmount: String?
        public let netAmount: String?
        public let currency: String?

        public init(grossAmount: String?, netAmount: String?, currency: String?) {
            self.grossAmount = grossAmount
            self.netAmount = netAmount
            self.currency = currency
        }

        public func deserialize() -> [String : Any] {
            var dict = [String: Any]()

            dict["gross_amount"] = grossAmount
            dict["net_amount"] = netAmount
            dict["currency"] = currency

            return dict
        }
    }
}

public extension CNIPayment {
    class CNICancellation: CNIObject, CNIModelDelegate {
        public let isAllowed: Bool?
        public let allowedUntil: Date?
        public let cancellationFee: Double?
        public let depositAmount: Double?
        public let minimumStay: Int?
        public let policy: String?

        public init(isAllowed: Bool?, allowedUntil: Date?, cancellationFee: Double?, depositAmount: Double?, minimumStay: Int?, policy: String?) {
            self.isAllowed = isAllowed
            self.allowedUntil = allowedUntil
            self.cancellationFee = cancellationFee
            self.depositAmount = depositAmount
            self.minimumStay = minimumStay
            self.policy = policy
        }

        public func deserialize() -> [String : Any] {
            var dict = [String: Any]()

            dict["is_allowed"] = isAllowed
            dict["allowed_until"] = dateAndTimeString(from: allowedUntil)
            dict["cancellation_fee"] = cancellationFee
            dict["deposit_amount"] = depositAmount
            dict["minimum_stay"] = minimumStay
            dict["policy"] = policy

            return dict
        }
    }
}
