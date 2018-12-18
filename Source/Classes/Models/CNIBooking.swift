//
//  CNIItinerary.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/14/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public struct Bookings: Codable {
    public private(set) var bookings: [Booking]
    
    public struct Booking: Codable {
        public private(set) var stay: Stay
        public private(set) var hotel: Hotel
        public private(set) var guest: Guest
    }
    
    public struct Guest: Codable {
        public private(set) var guestId: String?
        public private(set) var firstName: String?
        public private(set) var lastName: String?
        public private(set) var email: String?
        public private(set) var phone: String?
        
        private enum CodingKeys: String, CodingKey {
            case guestId = "id"
            case firstName = "first_name"
            case lastName = "last_name"
            case email
            case phone
        }
    }
    
    public struct Hotel: Codable {
        public private(set) var name: String?
        public private(set) var email: String?
        public private(set) var address: Address?
        public private(set) var phones: [String]?
        
        public struct Address: Codable {
            public private(set) var streetName: String?
            public private(set) var cityName: String?
            public private(set) var zipCode: String?
            
            private enum CodingKeys: String, CodingKey {
                case streetName = "street_name"
                case cityName = "city_name"
                case zipCode = "zip"
            }
        }
    }
    
    public struct Stay: Codable {
        public private(set) var arrivalDate: String?
        public private(set) var departureDate: String?
        public private(set) var reservationNumber: String?
        public private(set) var type: String?
        public private(set) var roomType: String?
        public private(set) var roomRate: String?
        public private(set) var services: [Service]?
        
        public struct Service: Codable {
            public private(set) var serviceDescription: String?
            public private(set) var amount: Double?
            public private(set) var currency: String?
            
            private enum CodingKeys: String, CodingKey {
                case serviceDescription = "description"
                case amount
                case currency
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case arrivalDate = "arrival_date"
            case departureDate = "departure_date"
            case reservationNumber = "reservation_number"
            case type
            case roomType = "room_type"
            case roomRate = "room_rate"
            case services
        }
    }
    
}

public class CNIBooking: CNIObject, CNIModelDelegate {
    public var stay: CNIStay?
    public var hotel: CNIHotel?
    public var guest: CNIGuest?
    
    public func map(json: JSON) {
        stay = CNIStay()
        hotel = CNIHotel()
        guest = CNIGuest()
        
        stay?.map(json: json["stay"])
        hotel?.map(json: json["hotel"])
        guest?.map(json: json["guest"])
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()
        
        dict["stay"] = stay?.deserialize()
        dict["hotel"] = hotel?.deserialize()
        dict["guest"] = guest?.deserialize()
        
        return dict
    }
}
