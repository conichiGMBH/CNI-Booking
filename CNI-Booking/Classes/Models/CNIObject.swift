//
//  CNIObject.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public class CNIObject: NSObject {
    let parseDateFormatter = DateFormatter()
    
    public override init() {
        super.init()
        parseDateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    public func parse(dateString: String?) -> Date! {
        if let dateString = dateString as String! {
            if let parsedDate = parseDateFormatter.date(from: dateString) {
                return parsedDate
            }
        }
        return Date()
    }

    public func display(date: Date?) -> String! {
        if let date = date as Date! {
            return parseDateFormatter.string(from: date)
        }
        return ""
    }
}
