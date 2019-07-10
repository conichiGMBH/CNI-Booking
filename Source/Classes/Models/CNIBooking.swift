//
//  CNIItinerary.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/14/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIBooking: CNIObject, CNIModelDelegate {
    public let traveler: CNITraveler?
    public let reservation: CNIReservation?
    public let hotel: CNIHotel?
    public let payment: CNIPayment?
    public let partner: CNIPartner?

    public init(traveler: CNITraveler?, reservation: CNIReservation?, hotel: CNIHotel?, payment: CNIPayment?, partner: CNIPartner?) {
        self.traveler = traveler
        self.reservation = reservation
        self.hotel = hotel
        self.payment = payment
        self.partner = partner
    }

    public func deserialize() -> [String: Any] {
        var dict = [String: Any]()

        dict["traveler"] = traveler?.deserialize()
        dict["reservation"] = reservation?.deserialize()
        dict["hotel"] = hotel?.deserialize()
        dict["payment"] = payment?.deserialize()
        dict["meta"] = ["partner": partner?.deserialize()]
        
        return dict
    }
}
