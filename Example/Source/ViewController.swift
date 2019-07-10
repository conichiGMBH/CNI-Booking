//
//  ViewController.swift
//  CNI-Itineraries
//
//  Created by vincentjacquesson on 04/23/2018.
//  Copyright (c) 2018 vincentjacquesson. All rights reserved.
//

import UIKit
import CNI_Itineraries

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var bookingManager: CNIBookingManager?
    let source = ""
    let token = ""

    var lastCreatedReservationNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
        
        bookingManager = CNIBookingManager(environment: .staging, apiToken: token, isTesting: true)
    }
    
    @IBAction func postButtonAction(_ sender: Any) {
        activityIndicator.isHidden = false
        textView.text = "\n" + textView.text

        let booking = CNIBooking(
            traveler: aTraveler(),
            reservation: aReservation(),
            hotel: aHotel(),
            payment: nil,
            partner: aPartner())
        bookingManager?.postBooking(source: source, booking: booking) { (response: CNIResponse<CNIStatus>) in
            self.activityIndicator.isHidden = true

            if response.isSuccessful, let status = response.result {
                self.lastCreatedReservationNumber = booking.reservation?.reservationNumber
                self.textView.text = "+ new booking posted: \(status.message!) - reservationNumber: \(self.lastCreatedReservationNumber!)"
            } else if !response.isSuccessful, let status = response.result {
                self.textView.text = "- status:\(status.status!) code:\(status.code!) - reason: \(status.reason!)"
            }
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        activityIndicator.isHidden = false
        textView.text = "\n" + textView.text

        guard let reservationNumber = self.lastCreatedReservationNumber else {
            assertionFailure()
            return
        }

        bookingManager?.cancelBooking(
            source: source,
            travelerId: aTraveler().id!,
            reservationNumber: reservationNumber,
            partnerPrimaryId: aPartner().primaryId!,
            partnerSecondaryIds: nil) { (response: CNIResponse<CNIStatus>) in
                self.activityIndicator.isHidden = true
                if response.isSuccessful, let status = response.result {
                    self.textView.text = "- booking canceled: \(status.message!)"
                } else if !response.isSuccessful, let status = response.result {
                    self.textView.text = "- cancel request:\ntravelerId: \(self.aTraveler().id!) - reservationNumber: \(reservationNumber) - partnerId: \(self.aPartner().primaryId!)"
                    self.textView.text += "\n- status:\(status.status!) code:\(status.code!) reason: \(status.reason!)"
                }
        }
    }
}

extension ViewController {
    func aTraveler() -> CNITraveler {
        let traveler = CNITraveler(
            id: "",
            firstName: "",
            lastName: "",
            email: "",
            phone: "",
            languageCode: nil,
            nationalityCode: nil,
            salutation: nil,
            address: nil,
            billingAddress: nil)
        return traveler
    }
    
    func aHotel() -> CNIHotel {
        let address = CNIAddress(
            street: "",
            city: "",
            zip: "",
            state: nil,
            country: "")

        let hotel = CNIHotel(
            id: "",
            secondaryId: nil,
            name: "",
            email: "",
            address: address,
            phones: [""])

        return hotel
    }
    
    func aReservation() -> CNIReservation {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
        let stay = CNIReservation(
            arrivalDate: today,
            departureDate: tomorrow,
            reservationNumber: "\(Date().timeIntervalSince1970)",
            reservationState: .booked,
            reservationType: nil,
            numberOfGuests: nil,
            roomType: nil,
            roomRate: nil,
            services: nil)

        return stay
    }

    func aPartner() -> CNIPartner {
        let partner = CNIPartner(primaryId: "", secondaryIds: nil)
        return partner
    }
}
