//
//  CNIAddress.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIAddress: CNIObject, CNIModelDelegate {
    public var streetName: String?
    public var cityName: String?
    public var zipCode: String?
    
    public func map(json: JSON) {
        streetName = json["street_name"].string
        cityName = json["city_name"].string
        zipCode = json["zip"].string
    }
    
    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()

        dict["street_name"] = streetName
        dict["city_name"] = cityName
        dict["zip"] = zipCode

        return dict
    }
}
