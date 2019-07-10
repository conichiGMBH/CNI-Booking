//
//  CNIStatus.swift
//  CNI-Itineraries
//
//  Created by David Henner on 04.07.19.
//  Copyright © 2019 conichi. All rights reserved.
//

import Foundation

public class CNIStatus: NSObject {
    public let status: String?
    public let code: Int?
    public let message: String?
    public let reason: String?

    init?(data: Data?) {
        guard let data = data else {
            return nil
        }
        let json = JSON(data)
        self.status = json["status"].string
        self.code = json["code"].int
        self.message = json["message"].string
        self.reason = json["reason"].string
    }
}
