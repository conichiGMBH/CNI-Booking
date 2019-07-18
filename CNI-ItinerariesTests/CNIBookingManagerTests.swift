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
    var data: Data!

    override func requestAction(endpoint: String, method: HttpMethod, source: String, completion: @escaping completionClosure<Data>) {
        self.endpoint = endpoint
        self.method = method
        completion(CNIResponse(result: data, error: nil, isSuccessful: isRequestSuccessful))
    }
}

final class CNIBookingManagerTests: QuickSpec {
    let successCode = 200
    let successMessage = "Success"
    let successStatus = "SUCCESS"
    let failureCode = 400
    let failureReason = "Failure"
    let failureStatus = "ERROR"

    override func spec() {
        let subject = CNIBookingManager(environment: .staging, apiToken: "token", isTesting: true)
        var requestManager: MockRequestManager!
        
        beforeEach {
            requestManager = MockRequestManager(environment: .staging, token: "token", isTesting: true)
            subject.requestManager = requestManager
        }

        describe(".getBookings") {
            let travelerdID = "123"
            let partnerID = "789"

            it("uses the bookings endpoint and POST method") {
                subject.getBookings(
                    source: "",
                    travelerID: travelerdID,
                    partnerPrimaryId: partnerID,
                    partnerSecondaryIds: nil,
                    success: {_ in},
                    failure: {_ in}
                )

                let traveler = CNITraveler(id: travelerdID)
                let partner = CNIPartner(primaryId: partnerID, secondaryIds: nil)
                let booking = CNIBooking(traveler: traveler, reservation: nil, hotel: nil, payment: nil, partner: partner)
                let expectedPayload = booking.deserialize()

                expect(requestManager.endpoint).to(equal(CNIBookingConstants.bookingsEndpoint))
                expect(requestManager.method).to(equal(HttpMethod.post(expectedPayload)))
            }

            context("when request succeeds") {
                let bookings: [String: Any] = [
                    "bookings": [
                        [
                            "stay": ["reservation_number": "123"],
                            "accepts_miles_and_more": true
                        ],
                        [
                            "stay": ["reservation_number": "345"],
                            "accepts_miles_and_more": true
                        ],
                        [
                            "stay": ["reservation_number": "678"],
                            "accepts_miles_and_more": true
                        ]
                    ]
                ]

                beforeEach {
                    let bookingsData = try! JSONSerialization.data(withJSONObject: bookings, options: .prettyPrinted)
                    requestManager.data = bookingsData
                    requestManager.isRequestSuccessful = true
                }

                it("returns successful CNIResponse containing array of bookings") {
                    var successResponse: CNIResponse<[CNIBooking]>?
                    var failureResponse: CNIResponse<CNIStatus>?

                    subject.getBookings(
                        source: "",
                        travelerID: travelerdID,
                        partnerPrimaryId: partnerID,
                        partnerSecondaryIds: nil,
                        success: {
                            (r: CNIResponse<[CNIBooking]>) in
                            successResponse = r
                        },
                        failure: {
                            (r: CNIResponse<CNIStatus>) in
                            failureResponse = r
                        }
                    )

                    expect(failureResponse).to(beNil())
                    expect(successResponse?.isSuccessful).toEventually(equal(true))
                    expect(successResponse?.error).toEventually(beNil())
                    expect(successResponse?.result).toEventuallyNot(beNil())
                    expect(successResponse?.result?.count).toEventually(equal(3))
                    expect(successResponse?.result?.first?.reservation?.reservationNumber).toEventually(equal("123"))
                    expect(successResponse?.result?.first?.acceptsMilesAndMore).toEventually(beTrue())
                }
            }

            context("when request fails") {
                beforeEach {
                    requestManager.data = self.failureData()
                    requestManager.isRequestSuccessful = false
                }

                it("returns unsuccessful CNIResponse containing status") {
                    var successResponse: CNIResponse<[CNIBooking]>?
                    var failureResponse: CNIResponse<CNIStatus>?

                    subject.getBookings(
                        source: "",
                        travelerID: travelerdID,
                        partnerPrimaryId: partnerID,
                        partnerSecondaryIds: nil,
                        success: {
                            (r: CNIResponse<[CNIBooking]>) in
                            successResponse = r
                        },
                        failure: {
                            (r: CNIResponse<CNIStatus>) in
                            failureResponse = r
                        }
                    )

                    expect(successResponse).to(beNil())
                    expect(failureResponse?.isSuccessful).toEventually(equal(false))
                    expect(failureResponse?.error).toEventually(beNil())
                    expect(failureResponse?.result).toEventuallyNot(beNil())
                    expect(failureResponse?.result?.code).toEventually(equal(self.failureCode))
                    expect(failureResponse?.result?.reason).toEventually(equal(self.failureReason))
                    expect(failureResponse?.result?.status).toEventually(equal(self.failureStatus))
                }
            }
        }
        
        describe(".postBooking") {
            var booking: CNIBooking!

            beforeEach {
                booking = CNIBooking(traveler: nil, reservation: nil, hotel: nil, payment: nil, partner: nil)
            }

            it("uses booking endpoint and POST method") {
                subject.postBooking(source: "", booking: booking, completion: {_ in})
                expect(requestManager.endpoint).to(equal(CNIBookingConstants.bookingEndpoint))
                expect(requestManager.method).to(equal(HttpMethod.post(booking.deserialize())))
            }
            
            context("when request succeeds") {
                beforeEach {
                    requestManager.data = self.successData()
                    requestManager.isRequestSuccessful = true
                }

                it("returns successful CNIResponse containing status") {
                    var response: CNIResponse<CNIStatus>!

                    subject.postBooking(source: "", booking: booking) { (r: CNIResponse<CNIStatus>) in
                        response = r
                    }

                    expect(response.isSuccessful).toEventually(equal(true))
                    expect(response.error).toEventually(beNil())
                    expect(response.result).toEventuallyNot(beNil())
                    expect(response.result?.code).toEventually(equal(self.successCode))
                    expect(response.result?.message).toEventually(equal(self.successMessage))
                    expect(response.result?.status).toEventually(equal(self.successStatus))
                }
            }
            
            context("when request fails") {
                beforeEach {
                    requestManager.data = self.failureData()
                    requestManager.isRequestSuccessful = false
                }

                it("returns unsuccessful CNIResponse containing status") {
                    var response: CNIResponse<CNIStatus>!

                    subject.postBooking(source: "", booking: booking) { (r: CNIResponse<CNIStatus>) in
                        response = r
                    }

                    expect(response.isSuccessful).toEventually(equal(false))
                    expect(response.error).toEventually(beNil())
                    expect(response.result).toEventuallyNot(beNil())
                    expect(response.result?.code).toEventually(equal(self.failureCode))
                    expect(response.result?.reason).toEventually(equal(self.failureReason))
                    expect(response.result?.status).toEventually(equal(self.failureStatus))
                }
            }
        }
        
        describe(".deleteBookingWith") {
            let travelerdID = "123"
            let reservationNumber = "456"
            let partnerID = "789"

            it("uses cancel booking endpoint and POST method") {
                subject.cancelBooking(source: "", travelerId: travelerdID, reservationNumber: reservationNumber, partnerPrimaryId: partnerID, partnerSecondaryIds: nil, completion: { _ in })

                let traveler = CNITraveler(id: travelerdID)
                let reservation = CNIReservation(reservationNumber: reservationNumber)
                let partner = CNIPartner(primaryId: partnerID, secondaryIds: nil)
                let booking = CNIBooking(traveler: traveler, reservation: reservation, hotel: nil, payment: nil, partner: partner)
                let expectedPayload = booking.deserialize()

                expect(requestManager.endpoint).to(equal(CNIBookingConstants.cancelBookingEndpoint))
                expect(requestManager.method).to(equal(HttpMethod.post(expectedPayload)))
            }
            
            context("when request succeeds") {
                beforeEach {
                    requestManager.data = self.successData()
                    requestManager.isRequestSuccessful = true
                }

                it("returns successful CNIResponse containing status") {
                    var response: CNIResponse<CNIStatus>!
                    subject.cancelBooking(source: "", travelerId: travelerdID, reservationNumber: reservationNumber, partnerPrimaryId: partnerID, partnerSecondaryIds: nil, completion: {
                        (r: CNIResponse<CNIStatus>) in
                        response = r
                    })

                    expect(response.isSuccessful).toEventually(equal(true))
                    expect(response.error).toEventually(beNil())
                    expect(response.result).toEventuallyNot(beNil())
                    expect(response.result?.code).toEventually(equal(self.successCode))
                    expect(response.result?.message).toEventually(equal(self.successMessage))
                    expect(response.result?.status).toEventually(equal(self.successStatus))
                }
            }
            
            context("when request fails") {
                beforeEach {
                    requestManager.data = self.failureData()
                    requestManager.isRequestSuccessful = false
                }

                it("returns unsuccessful CNIResponse containing status") {
                    var response: CNIResponse<CNIStatus>!

                    subject.cancelBooking(source: "", travelerId: travelerdID, reservationNumber: reservationNumber, partnerPrimaryId: partnerID, partnerSecondaryIds: nil, completion: {
                        (r: CNIResponse<CNIStatus>) in
                        response = r
                    })

                    expect(response.isSuccessful).toEventually(equal(false))
                    expect(response.error).toEventually(beNil())
                    expect(response.result).toEventuallyNot(beNil())
                    expect(response.result?.code).toEventually(equal(self.failureCode))
                    expect(response.result?.reason).toEventually(equal(self.failureReason))
                    expect(response.result?.status).toEventually(equal(self.failureStatus))                }
            }
        }
    }

    func successData() -> Data {
        let json: [String: Any] = [
            "status": successStatus,
            "code": successCode,
            "message": successMessage]
        let successData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return successData
    }

    func failureData() -> Data {
        let json: [String: Any] = [
            "status": failureStatus,
            "code": failureCode,
            "reason": failureReason]
        let failureData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return failureData
    }
}
