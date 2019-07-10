//
//  CNIBillingAddress.swift
//  CNI-Itineraries
//
//  Created by David Henner on 03.07.19.
//  Copyright © 2019 conichi. All rights reserved.
//

import Foundation

public class CNIBillingAddress: CNIObject, CNIModelDelegate {
    public let street: String?
    public let city: String?
    public let zip: String?
    public let state: String?
    public let country: String?
    public let company: String?
    public let department: String?
    public let costCenter: String?
    public let vatId: String?

    public init(street: String?, city: String?, zip: String?, state: String?, country: String?, company: String?, department: String?, costCenter: String?, vatId: String?) {
        self.street = street
        self.city = city
        self.zip = zip
        self.state = state
        self.country = country
        self.company = company
        self.department = department
        self.costCenter = costCenter
        self.vatId = vatId
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()

        dict["street"] = street
        dict["city"] = city
        dict["zip"] = zip
        dict["state"] = state
        dict["country"] = country
        dict["company"] = company
        dict["department"] = department
        dict["cost_center"] = costCenter
        dict["vat_id"] = vatId

        return dict
    }}
