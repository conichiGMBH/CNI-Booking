//
//  CNIBookingManager.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/19/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

struct CNIBookingConstants {
    static let bookingsEndpoint = "itinerary/bookings"
    static let bookingsForIdEndpoint = "itinerary/bookings/id?value="
}

public class CNIBookingManager: NSObject {
    let requestManager: CNIRequestManager?
    
    public init(username: String!,
         password: String!,
         consumerKey: String!,
         environment: String!) {
        requestManager = CNIRequestManager(username: username,
                                           password: password,
                                           consumerKey: consumerKey,
                                           environment: environment)
    }
    
    public func fetchBookings(success: @escaping (_ results: [Bookings.Booking]) -> Void,
                              failure: @escaping (_ error: Error) -> Void) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .get(endpoint: CNIBookingConstants.bookingsEndpoint,
                 success: { (data) in
                    do {
                        let itineraries: Bookings = try JSONDecoder().decode(Bookings.self, from: data)
                        
                        DispatchQueue.main.async {
                            success(itineraries.bookings)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            failure(error)
                        }
                    }
                    
            }) { (error) in
                DispatchQueue.main.async {
                    failure(error)
                }
        }
    }
    
    public func getBookingsWith(success: @escaping (_ results: [CNIBooking]) -> Void,
                                         failure: @escaping (_ error: Error) -> Void) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .get(endpoint: CNIBookingConstants.bookingsEndpoint,
                 success: { (data) in
                    var itineraries = [CNIBooking]()
                    let json = JSON(data)
                    for (_, itineraryJSON) in json["bookings"] {
                        let itinerary = CNIBooking()
                        itinerary.map(json: itineraryJSON)
                        itineraries.append(itinerary)
                    }
                    DispatchQueue.main.async {
                        success(itineraries)
                    }
            }) { (error) in
                DispatchQueue.main.async {
                    failure(error)
                }
        }
    }
    
    public func getBookingsFor(guestId: String,
                                        success: @escaping (_ results: [CNIBooking]) -> Void,
                                        failure: @escaping (_ error: Error) -> Void) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .get(endpoint: CNIBookingConstants.bookingsForIdEndpoint + guestId,
                 success: { (data) in
                    var itineraries = [CNIBooking]()
                    let json = JSON(data)
                    for (_, itineraryJSON) in json["bookings"] {
                        let itinerary = CNIBooking()
                        itinerary.map(json: itineraryJSON)
                        itineraries.append(itinerary)
                    }
                    DispatchQueue.main.async {
                        success(itineraries)
                    }
            }) { (error) in
                DispatchQueue.main.async {
                    failure(error)
                }
        }
    }
    
    public func postBookingWith(data: [String: Any],
                                        success: @escaping (_ result: Bool) -> Void,
                                        failure: @escaping (_ error: Error) -> Void) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .post(endpoint: CNIBookingConstants.bookingsEndpoint,
                  data: data,
                  success: { (data) in
                    DispatchQueue.main.async {
                        success(true)
                    }
            }) { (error) in
                DispatchQueue.main.async {
                    failure(error)
                }
        }
    }
    
    public func deleteBookingWith(data: [String: Any],
                                          success: @escaping (_ result: Bool) -> Void,
                                          failure: @escaping (_ error: Error) -> Void) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .delete(endpoint: CNIBookingConstants.bookingsEndpoint,
                    data: data,
                    success: { (data) in
                        DispatchQueue.main.async {
                            success(true)
                        }
            }) { (error) in
                DispatchQueue.main.async {
                    failure(error)
                }
        }
    }
}
