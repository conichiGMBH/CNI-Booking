//
//  CNIBookingManagerTests.swift
//  CNI-ItinerariesTests
//
//  Created by Kai-Hong Tseng on 1/9/19.
//  Copyright © 2019 conichi. All rights reserved.
//

import Quick
import Nimble

@testable import CNI_Itineraries

class MockRequestManager: CNIRequestManager {
    var endpoint: String?
    var method: HttpMethod?
    var isRequestSuccessful = true
    let bookingJSONString = """
    {
        "bookings": [{
            "guest": {
                "last_name": "Tseng",
                "phone": "013333333333",
                "email": "joseph.tseng@conichi.com",
                "id": "42424242",
                "first_name": "Joseph"
            },
            "hotel": {
                "phones": [
                "013333333333"],
                "email": "conichi@conichi.com",
                "name": "conichi",
                "address": {
                    "street_name": "Ohlauer Str. 43",
                    "zip": "10999",
                    "city_name": "Berlin"
                }
            },
            "stay": {
                "room_rate": "42",
                "type": "email",
                "arrival_date": "2018-06-26",
                "reservation_number": "1545302100.89207",
                "services": [{
                "amount": 42,
                "currency": "€",
                "description": "pool"
                }, {
                "amount": 3,
                "currency": "€",
                "description": "netflix"
                }],
                "departure_date": "2018-06-27",
                "room_type": "penthouse"
            }
        }]
    }
"""
    
    override func requestAction(endpoint: String, method: HttpMethod, success: @escaping successClosure<Data>, failure: @escaping failureClosure) {
        self.endpoint = endpoint
        self.method = method
        if isRequestSuccessful {
            success(bookingJSONString.data(using: .utf8)!)
        } else {
            failure(CNIHttpError.unknownError)
        }
    }
}

final class CNIBookingManagerTests: QuickSpec {
    override func spec() {
        let subject = CNIBookingManager(username: "test-user", password: "test", consumerKey: "test-key", environment: "Staging")
        var requestManager: MockRequestManager!
        
        beforeEach {
            requestManager = MockRequestManager(username: "test-user", password: "test", consumerKey: "test-key", environment: "Staging")
            subject.requestManager = requestManager
        }
        
        describe(".getBookingsFor") {
            it("uses bookingsForID endpoint and GET method") {
                subject.getBookingsFor(guestId: "123", success: { _ in }, failure: { _ in })
                expect(requestManager.endpoint).to(equal(CNIBookingConstants.bookingsForIdEndpoint + "123"))
                expect(requestManager.method).to(equal(HttpMethod.get))
            }
            
            context("when request succeeds") {
                it("returns correct booking data") {
                    var resultBookings: [CNIBooking]!
                    subject.getBookingsFor(guestId: "", success: { (bookings) in
                        resultBookings = bookings
                    }, failure: { _ in })
                    expect(resultBookings.first!.guest!.guestId!).toEventually(equal("42424242"))
                    expect(resultBookings.first!.hotel!.name!).toEventually(equal("conichi"))
                }
            }
            
            context("when request fails") {
                it("gives an error") {
                    var resultError: Error!
                    requestManager.isRequestSuccessful = false
                    subject.getBookingsFor(guestId: "123", success: { _ in }, failure: { (error) in
                        resultError = error
                    })
                    expect(resultError).toEventually(matchError(CNIHttpError.unknownError))
                }
            }
        }
        
        describe(".postBookingWith") {
            it("uses bookings endpoint and POST method") {
                subject.postBookingWith(data: ["test": "123"], success: { _ in }, failure: { _ in })
                expect(requestManager.endpoint).to(equal(CNIBookingConstants.bookingsEndpoint))
                expect(requestManager.method).to(equal(HttpMethod.post(["test": "123"])))
            }
            
            context("when request succeeds") {
                it("returns true") {
                    var expectedResult: Bool!
                    subject.postBookingWith(data: [:], success: { (result) in
                        expectedResult = result
                    }, failure: { _ in })
                    expect(expectedResult).toEventually(equal(true))
                }
            }
            
            context("when request fails") {
                it("gives an error") {
                    var resultError: Error!
                    requestManager.isRequestSuccessful = false
                    subject.postBookingWith(data: [:], success: { _ in }, failure: { (error) in
                        resultError = error
                    })
                    expect(resultError).toEventually(matchError(CNIHttpError.unknownError))
                }
            }
        }
        
        describe(".deleteBookingWith") {
            it("uses cancel booking endpoint and POST method") {
                subject.deleteBookingWith(guestId: "123", reservationNumber: "456", success: { _ in }, failure: { _ in })
                var expectedPayload = [String: Any]()
                expectedPayload["guest"] = ["id": "123"]
                expectedPayload["stay"] = ["reservation_number": "456"]

                expect(requestManager.endpoint).to(equal(CNIBookingConstants.cancelBookingEndpoint))
                expect(requestManager.method).to(equal(HttpMethod.post(expectedPayload)))
            }
            
            context("when request succeeds") {
                it("returns true") {
                    var expectedResult: Bool!
                    subject.deleteBookingWith(guestId: "123", reservationNumber: "456", success: { (result) in
                        expectedResult = result
                    }, failure: { _ in })
                    expect(expectedResult).toEventually(equal(true))
                }
            }
            
            context("when request fails") {
                it("gives an error") {
                    var resultError: Error!
                    requestManager.isRequestSuccessful = false
                    subject.deleteBookingWith(guestId: "123", reservationNumber: "456", success: { _ in }, failure: { (error) in
                        resultError = error
                    })
                    expect(resultError).toEventually(matchError(CNIHttpError.unknownError))
                }
            }
        }
    }
}
