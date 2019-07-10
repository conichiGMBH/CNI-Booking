//
//  CNITraveler.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNITraveler: CNIObject, CNIModelDelegate {
    public let id: String?
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let phone: String?
    public let languageCode: String?
    public let nationalityCode: String?
    public let salutation: String?
    public let address: CNIAddress?
    public let billingAddress: CNIBillingAddress?

    public init(id: String?, firstName: String?, lastName: String?, email: String?, phone: String?, languageCode: String?, nationalityCode: String?, salutation: String?, address: CNIAddress?, billingAddress: CNIBillingAddress?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.languageCode = languageCode
        self.nationalityCode = nationalityCode
        self.salutation = salutation
        self.address = address
        self.billingAddress = billingAddress
    }

    internal convenience init(id: String?) {
        self.init(id: id,
                  firstName: nil,
                  lastName: nil,
                  email: nil,
                  phone: nil,
                  languageCode: nil,
                  nationalityCode: nil,
                  salutation: nil,
                  address: nil,
                  billingAddress: nil)
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["id"] = id
        dict["first_name"] = firstName
        dict["last_name"] = lastName
        dict["email"] = email
        dict["phone"] = phone
        dict["language_code"] = languageCode
        dict["nationality_code"] = nationalityCode
        dict["salutation"] = salutation
        dict["address"] = address?.deserialize()
        dict["billing_address"] = billingAddress?.deserialize()

        return dict
    }
}
