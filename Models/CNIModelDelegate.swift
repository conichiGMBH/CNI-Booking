//
//  CNIModelDelegate.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/12/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import Foundation

public protocol CNIModelDelegate {
    func map(json: JSON)
    func deserialize() -> [String: Any]
}
