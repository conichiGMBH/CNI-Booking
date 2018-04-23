//
//  CNIGuest.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

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
