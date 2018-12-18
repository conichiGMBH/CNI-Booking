//
//  CNIStay.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIStay: CNIObject, CNIModelDelegate {
    public var arrivalDate: Date?
    public var departureDate: Date?
    public var reservationNumber: String?
    public var type: String?
    public var roomType: String?
    public var roomRate: String?
    public var services: [CNIService]?
    
    public func map(json: JSON) {
        arrivalDate = parse(dateString: json["arrival_date"].string)
        departureDate = parse(dateString: json["departure_date"].string)
        reservationNumber = json["reservation_number"].string
        type = json["type"].string ?? "email"
        roomType = json["room_type"].string
        roomRate = json["room_rate"].string
        var services = [CNIService]()
        for (_, serviceDict) in json["services"] {
            let service = CNIService()
            service.map(json: serviceDict)
            services += [service]
        }
        self.services = services
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["arrival_date"] = display(date: arrivalDate)
        dict["departure_date"] = display(date: departureDate)
        dict["reservation_number"] = reservationNumber
        dict["type"] = "email"
        dict["room_type"] = roomType
        dict["room_rate"] = roomRate
        var servicesJSONArray = [[String: Any]]()
        if let services = services {
            if services.count > 0 {
                for service in services {
                    servicesJSONArray.append(service.deserialize())
                }
            }
        }
        dict["services"] = servicesJSONArray

        return dict
    }
}
