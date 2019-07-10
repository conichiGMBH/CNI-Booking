//
//  CNIBookingManager.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/19/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

struct CNIBookingConstants {
    static let bookingEndpoint = "booking"
    static let cancelBookingEndpoint = "booking/cancel"
}

public class CNIBookingManager: NSObject {
    var requestManager: CNIRequestManager?
    
    public init(environment: CNIEnvironment,
                apiToken: String,
                isTesting: Bool) {
        requestManager = CNIRequestManager(environment: environment,
                                           token: apiToken,
                                           isTesting: isTesting)
    }
    
    public func postBooking(source: String,
                            booking: CNIBooking,
                            completion: @escaping completionClosure<CNIStatus>) {
        guard let requestManager = requestManager else {
            completion(CNIResponse(result: nil, error: CNIHttpError.unauthorized, isSuccessful: false))
            return
        }
        let data = booking.deserialize()
        requestManager
            .requestAction(endpoint: CNIBookingConstants.bookingEndpoint,
                method: .post(data),
                source: source) { (response: CNIResponse<Data>) in
                    let status = CNIStatus(data: response.result)
                    DispatchQueue.main.async {
                        completion(CNIResponse(result: status, error: response.error, isSuccessful: response.isSuccessful))
                    }
        }
    }

    public func cancelBooking(source: String,
                              travelerId: String,
                              reservationNumber: String,
                              partnerPrimaryId: String,
                              partnerSecondaryIds: [String]?,
                              completion: @escaping completionClosure<CNIStatus>) {
        guard let requestManager = requestManager else {
            completion(CNIResponse(result: nil, error: CNIHttpError.unauthorized, isSuccessful: false))
            return
        }

        let traveler = CNITraveler(id: travelerId)
        let reservation = CNIReservation(reservationNumber: reservationNumber)
        let partner = CNIPartner(primaryId: partnerPrimaryId, secondaryIds: partnerSecondaryIds)
        let booking = CNIBooking(traveler: traveler, reservation: reservation, hotel: nil, payment: nil, partner: partner)
        let data = booking.deserialize()

        requestManager.requestAction(
                endpoint: CNIBookingConstants.cancelBookingEndpoint,
                method: .post(data),
                source: source) { (response: CNIResponse<Data>) in
                    let status = CNIStatus(data: response.result)
                    DispatchQueue.main.async {
                        completion(CNIResponse(result: status, error: response.error, isSuccessful: response.isSuccessful))
                    }
        }
    }
}
