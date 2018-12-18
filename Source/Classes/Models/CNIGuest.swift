//
//  CNIGuest.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public struct Guest: Codable {
    public private(set) var guestId: String
    public private(set) var firstName: String
    public private(set) var lastName: String
    public private(set) var email: String
    public private(set) var phone: String
    
    private enum CodingKeys: String, CodingKey {
        case guestId = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
    }
}

public class CNIGuest: CNIObject, CNIModelDelegate {
    public var guestId: String?
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var phone: String?

    public func map(json: JSON) {
        guestId = json["id"].string
        firstName = json["first_name"].string
        lastName = json["last_name"].string
        email = json["email"].string
        phone = json["phone"].string
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()

        dict["id"] = guestId
        dict["first_name"] = firstName
        dict["last_name"] = lastName
        dict["email"] = email
        dict["phone"] = phone

        return dict
    }
}
