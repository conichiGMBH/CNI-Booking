//
//  CNIHotel.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIHotel: CNIObject, CNIModelDelegate {
    public var id: String?
    public var secondaryId: String?
    public var name: String?
    public var email: String?
    public var address: CNIAddress?
    public var phones: [String]?
    
    public func map(json: JSON) {
        id = json["id"].string
        secondaryId = json["secondary_id"].string
        name = json["name"].string
        email = json["email"].string
        address = CNIAddress()
        address?.map(json: json["address"])
        phones = [String]()
        for (_, phoneJSON) in json["phones"] {
            if let phone = phoneJSON.string {
                phones?.append(phone)
            }
        }
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
