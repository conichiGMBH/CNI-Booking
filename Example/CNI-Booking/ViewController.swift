//
//  ViewController.swift
//  CNI-Booking
//
//  Created by vincentjacquesson on 04/23/2018.
//  Copyright (c) 2018 vincentjacquesson. All rights reserved.
//

import UIKit
import CNI_Booking

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var bookingManager: CNIBookingManager?
    var bookingsForId = [CNIBooking]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
        
        bookingManager = CNIBookingManager(username: "",
                                           password: "",
                                           consumerKey: "",
                                           environment: "")
    }
    
    @IBAction func getButtonAction(_ sender: Any) {
        textView.text = "\n" + textView.text
        activityIndicator.isHidden = false
        bookingManager?.getBookingsWith(success: { (itineraries) in
            var result = ""
            for itinerary in itineraries {
                result = result + "\(itinerary.guest?.lastName ?? "") in \(itinerary.hotel?.name ?? "") (\(itinerary.stay?.reservationNumber ?? ""))\n"
            }
            self.activityIndicator.isHidden = true
            self.textView.text = result + self.textView.text
        }) { (error) in
            self.activityIndicator.isHidden = true
            self.textView.text = "Error: \(error)" + self.textView.text + "\n"
        }
    }
    
    @IBAction func getForIDButtonAction(_ sender: Any) {
        activityIndicator.isHidden = false
        textView.text = "\n" + textView.text
        bookingsForId = [CNIBooking]()
        bookingManager?
            .getBookingsFor(guestId: "42424242",
                            success: { (itineraries) in
                                var result = ""
                                self.bookingsForId = itineraries
                                if itineraries.count == 0 {
                                    result = "No booking for ID\n"
                                } else {
                                    for itinerary in itineraries {
                                        result += "\(itinerary.guest?.lastName ?? "") in \(itinerary.hotel?.name ?? "") (\(itinerary.stay?.reservationNumber ?? ""))\n"
                                    }
                                }
                                self.activityIndicator.isHidden = true
                                self.textView.text = result + self.textView.text
            }) { (error) in
                self.activityIndicator.isHidden = true
                self.textView.text = "Error: \(error)" + self.textView.text + "\n"
        }
    }
    
    @IBAction func postButtonAction(_ sender: Any) {
        activityIndicator.isHidden = false
        textView.text = "\n" + textView.text
        let guest = aGuest()
        let hotel = aHotel()
        let stay = aStay()
        bookingManager?.postBookingWith(data: [
            "guest": guest.deserialize(),
            "hotel": hotel.deserialize(),
            "stay": stay.deserialize()
            ], success: { (result) in
                self.activityIndicator.isHidden = true
                self.textView.text = "+ new booking Posted\n" + self.textView.text
        }) { (error) in
            self.activityIndicator.isHidden = true
            self.textView.text = "Error: \(error)" + self.textView.text + "\n"
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        textView.text = "\n" + textView.text
        if bookingsForId.count == 0 {
            self.textView.text = "Nothing to delete, post and get bookings before\n" + textView.text
        } else {
            activityIndicator.isHidden = false
            var s = ""
            var i = 0
            for itinerary in bookingsForId {
                s += "- \(itinerary.stay?.reservationNumber ?? "") deleted\n"
                bookingManager?
                    .deleteBookingWith(data: itinerary.deserialize(),
                                       success: { (result) in
                                        i += 1
                                        if i >= self.bookingsForId.count {
                                            self.activityIndicator.isHidden = true
                                        }
                    }, failure: { (error) in
                        self.activityIndicator.isHidden = true
                        self.textView.text = "Error: \(error)" + self.textView.text + "\n"
                    })
            }
            self.bookingsForId = [CNIBooking]()
            self.textView.text = s + self.textView.text + "\n"
        }
    }
}

extension ViewController {
    func aGuest() -> CNIGuest {
        let guest = CNIGuest()
        guest.map(json: [
            "id": "42424242",
            "first_name": "Vincent",
            "last_name": "Jacquesson",
            "email": "vincent.jacquesson@conichi.com",
            "phone": "013333333333"
            ])
        return guest
    }
    
    func aHotel() -> CNIHotel {
        let hotel = CNIHotel()
        hotel.map(json: [
            "name": "conichi",
            "email": "conichi@conichi.com",
            "address": [
                "street_name": "Ohlauer Str. 43",
                "city_name": "Berlin",
                "zip": "10999"
            ],
            "phones": [
                "013333333333"
            ]
            ])
        return hotel
    }
    
    func aStay() -> CNIStay {
        let stay = CNIStay()
        stay.map(json: [
            "arrival_date": "2018-06-26",
            "departure_date": "2018-06-27",
            "reservation_number": "\(Date().timeIntervalSince1970)",
            "type": "email",
            "room_type": "penthouse",
            "room_rate": "42",
            "services": [
                [
                    "description": "pool",
                    "amount": 42.0,
                    "currency": "€"
                ],[
                    "description": "netflix",
                    "amount": 3.0,
                    "currency": "€"
                ]
            ]
            ])
        return stay
    }
}
