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
    var requestManager: CNIRequestManager?
    
    public init(username: String!,
         password: String!,
         consumerKey: String!,
         environment: String!) {
        requestManager = CNIRequestManager(username: username,
                                           password: password,
                                           consumerKey: consumerKey,
                                           environment: environment)
    }
    
    public func getBookingsWith(success: @escaping successClosure<[CNIBooking]>,
                                failure: @escaping failureClosure) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager.requestAction(endpoint: CNIBookingConstants.bookingsEndpoint,
             method: .get,
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
                }},
             failure: { (error) in
                DispatchQueue.main.async {
                    failure(error)
                }
            })
    }
    
    public func getBookingsFor(guestId: String,
                               success: @escaping successClosure<[CNIBooking]>,
                               failure: @escaping failureClosure) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .requestAction(endpoint: CNIBookingConstants.bookingsForIdEndpoint + guestId,
                method: .get,
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
                                success: @escaping successClosure<Bool>,
                                failure: @escaping failureClosure) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .requestAction(endpoint: CNIBookingConstants.bookingsEndpoint,
                method: .post(data),
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
                                  success: @escaping successClosure<Bool>,
                                  failure: @escaping failureClosure) {
        guard let requestManager = requestManager else {
            failure(CNIHttpError.unauthorized)
            return
        }
        
        requestManager
            .requestAction(endpoint: CNIBookingConstants.bookingsEndpoint,
                   method: .delete(data),
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
