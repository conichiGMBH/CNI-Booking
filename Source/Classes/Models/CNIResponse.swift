//
//  CNIResponse.swift
//  CNI-Itineraries
//
//  Created by David Henner on 04.07.19.
//  Copyright © 2019 conichi. All rights reserved.
//

import Foundation

public class CNIResponse<T>: NSObject {
    public let result: T?
    public let error: Error?
    public let isSuccessful: Bool

    init(result: T?, error: Error?, isSuccessful: Bool) {
        self.result = result
        self.error = error
        self.isSuccessful = isSuccessful
    }
}
