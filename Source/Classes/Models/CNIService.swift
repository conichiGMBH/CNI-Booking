//
//  CNIService.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIService: CNIObject, CNIModelDelegate {
    public let serviceDescription: String?
    public let amount: Double?
    public let currency: String?

    public init(serviceDescription: String?, amount: Double?, currency: String?) {
        self.serviceDescription = serviceDescription
        self.amount = amount
        self.currency = currency
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["description"] = serviceDescription
        dict["amount"] = amount
        dict["currency"] = currency
        
        return dict
    }
}
