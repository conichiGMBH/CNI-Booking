//
//  CNIHotel.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIHotel: CNIObject, CNIModelDelegate {
    public let id: String?
    public let secondaryId: String?
    public let name: String?
    public let email: String?
    public let address: CNIAddress?
    public let phones: [String]?

    public init(id: String?, secondaryId: String?, name: String?, email: String?, address: CNIAddress?, phones: [String]?) {
        self.id = id
        self.secondaryId = secondaryId
        self.name = name
        self.email = email
        self.address = address
        self.phones = phones ?? []
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()

        dict["id"] = id
        dict["secondary_id"] = secondaryId
        dict["name"] = name
        dict["email"] = email
        dict["address"] = address?.deserialize()
        var phonesJSONArray = [String]()
        for phone in phones! {
            phonesJSONArray.append(phone)
        }
        dict["phones"] = phonesJSONArray
        
        return dict
    }
}
