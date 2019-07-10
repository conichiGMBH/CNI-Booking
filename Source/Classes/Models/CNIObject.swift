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

    public func dateString(from date: Date?) -> String? {
        parseDateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = date else {
            return nil
        }

        return parseDateFormatter.string(from: date)
    }

    public func dateAndTimeString(from date: Date?) -> String? {
        parseDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S"

        guard let date = date else {
            return nil
        }

        return parseDateFormatter.string(from: date)
    }
}
