//
//  CNIAddress.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIAddress: CNIObject, CNIModelDelegate {
    public let street: String?
    public let city: String?
    public let zip: String?
    public let state: String?
    public let country: String?

    public init(street: String?, city: String?, zip: String?, state: String?, country: String?) {
        self.street = street
        self.city = city
        self.zip = zip
        self.state = state
        self.country = country
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()

        dict["street"] = street
        dict["city"] = city
        dict["zip"] = zip
        dict["state"] = state
        dict["country"] = country

        return dict
    }
}
