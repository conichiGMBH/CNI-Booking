//
//  CNINetworkConfiguration.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/14/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

public enum CNIEnvironment {
    case dev
    case staging
    case production
}

fileprivate struct CNINetworkConstants {
    static let devBaseURL = "https://transformer.dev.conichi.com/api/2/"
    static let stagingBaseURL = "https://transformer.staging.conichi.com/api/2/"
    static let productionBaseURL = "https://transformer.conichi.com/api/2/"
}

class CNINetworkConfiguration: NSObject {
    static let protocolVersion: String = "1"
    var token: String
    var baseURL: String

    init(token: String,
         environment: CNIEnvironment) {

        self.token = token
        switch environment {
        case .dev:
            baseURL = CNINetworkConstants.devBaseURL
        case .staging:
            baseURL = CNINetworkConstants.stagingBaseURL
        case .production:
            baseURL = CNINetworkConstants.productionBaseURL
        }

        super.init()
    }

    func protocolVersion() -> String {
        return CNINetworkConfiguration.protocolVersion
    }
}
