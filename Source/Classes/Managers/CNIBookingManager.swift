//
//  CNIBookingManager.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/19/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

struct CNIBookingConstants {
    static let bookingsEndpoint = "booking/retrieve-processed"
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

    public func getBookings(source: String,
                            travelerID: String,
                            partnerPrimaryId: String,
                            partnerSecondaryIds: [String]?,
                            success: @escaping completionClosure<[CNIBooking]>,
                            failure: @escaping completionClosure<CNIStatus>) {
        guard let requestManager = requestManager else {
            failure(CNIResponse(result: nil, error: CNIHttpError.unauthorized, isSuccessful: false))
            return
        }

        let traveler = CNITraveler(id: travelerID)
        let partner = CNIPartner(primaryId: partnerPrimaryId, secondaryIds: partnerSecondaryIds)
        let booking = CNIBooking(traveler: traveler, reservation: nil, hotel: nil, payment: nil, partner: partner)
        let params = booking.deserialize()

        requestManager.requestAction(endpoint: CNIBookingConstants.bookingsEndpoint, method: .post(params), source: source) {
            (response: CNIResponse<Data>) in
            guard response.isSuccessful, let data = response.result else {
                let status = CNIStatus(data: response.result)
                DispatchQueue.main.async {
                    failure(CNIResponse(result: status, error: response.error, isSuccessful: false))
                }
                return
            }
            let json = JSON(data)
            var bookings = [CNIBooking]()
            for (_, bookingJSON) in json["bookings"] {
                let booking = CNIBooking()
                booking.map(json: bookingJSON)
                bookings.append(booking)
            }
            DispatchQueue.main.async {
                success(CNIResponse(result: bookings, error: response.error, isSuccessful: true))
            }
        }
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
