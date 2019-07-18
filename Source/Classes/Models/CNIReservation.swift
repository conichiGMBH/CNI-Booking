//
//  CNIReservation.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public enum CNIReservationState: String {
    case booked = "booked"
    case cancelled = "cancelled"
}

public enum CNIReservationType: String {
    case standard = "standard"
    case guaranteed = "guaranteed"
}

public class CNIReservation: CNIObject, CNIModelDelegate {
    public let arrivalDate: Date?
    public let departureDate: Date?
    public private(set) var reservationNumber: String?
    public let reservationState: CNIReservationState?
    public let reservationType: CNIReservationType?
    public let numberOfGuests: Int?
    public let roomType: String?
    public let roomRate: String?
    public let services: [CNIService]?
    
    public init(arrivalDate: Date?, departureDate: Date?, reservationNumber: String?, reservationState: CNIReservationState?, reservationType: CNIReservationType?, numberOfGuests: Int?, roomType: String?, roomRate: String?, services: [CNIService]?) {
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.reservationNumber = reservationNumber
        self.reservationState = reservationState
        self.reservationType = reservationType
        self.numberOfGuests = numberOfGuests
        self.roomType = roomType
        self.roomRate = roomRate
        self.services = services
    }

    internal convenience init(reservationNumber: String) {
        self.init(arrivalDate: nil, departureDate: nil, reservationNumber: reservationNumber, reservationState: nil, reservationType: nil, numberOfGuests: nil, roomType: nil, roomRate: nil, services: nil)
    }

    internal convenience override init() {
        self.init(arrivalDate: nil, departureDate: nil, reservationNumber: nil, reservationState: nil, reservationType: nil, numberOfGuests: nil, roomType: nil, roomRate: nil, services: nil)
    }

    public func map(json: JSON) {
        reservationNumber = json["reservation_number"].string
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["arrival_date"] = dateString(from: arrivalDate)
        dict["departure_date"] = dateString(from: departureDate)
        dict["reservation_number"] = reservationNumber
        dict["reservation_state"] = reservationState?.rawValue
        dict["reservation_type"] = reservationType?.rawValue
        dict["number_of_guests"] = numberOfGuests
        dict["room_type"] = roomType
        dict["room_rate"] = roomRate
        if let services = services, services.count > 0 {
            var servicesJSONArray = [[String: Any]]()
            for service in services {
                servicesJSONArray.append(service.deserialize())
            }
            dict["services"] = servicesJSONArray
        }

        return dict
    }
}
