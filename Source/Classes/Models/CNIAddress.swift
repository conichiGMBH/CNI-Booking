//
//  CNIAddress.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public struct Address: Codable {
    public private(set) var streetName: String
    public private(set) var cityName: String
    public private(set) var zipCode: String
    
    private enum CodingKeys: String, CodingKey {
        case streetName = "street_name"
        case cityName = "city_name"
        case zipCode = "zip"
    }

}

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
