//
//  CNIService.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIService: CNIObject, CNIModelDelegate {
    public var serviceDescription: String?
    public var amount: Double?
    public var currency: String?
    
    public func map(json: JSON) {
        serviceDescription = json["description"].string
        amount = json["amount"].double
        currency = json["currency"].string
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["description"] = serviceDescription
        dict["amount"] = amount
        dict["currency"] = currency
        
        return dict
    }
}
