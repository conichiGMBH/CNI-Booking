//
//  CNIItinerary.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/14/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

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
