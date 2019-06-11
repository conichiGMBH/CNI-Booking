//
//  CNINetworkConfiguration.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/14/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

enum CNIEnvironment {
    case dev
    case staging
    case production
    case unknowEnvironment
}

struct CNINetworkConstants {
    static let devBaseURL = "https://app.dev.conichi.com/api/v3/"
    static let stagingBaseURL = "https://app.staging.conichi.com/api/v3/"
    static let productionBaseURL = "https://app.conichi.com/api/v3/"
}

class CNINetworkConfiguration: NSObject {
    static let protocolVersion: String = "2"
    var username: String
    var password: String
    var consumerKey: String
    var environment: CNIEnvironment
    var baseURL: String
    var authString: String

    init(username: String,
         password: String,
         consumerKey: String,
         environment: String) {
        self.username = username
        self.password = password
        self.consumerKey = consumerKey
        let userPasswordString = username + ":" + password
        authString = ""
        if let userPasswordData = userPasswordString.data(using: String.Encoding.utf8) {
            let base64EncodedCredential = userPasswordData.base64EncodedString()
            authString = "Basic \(base64EncodedCredential)"
        }

        switch environment.lowercased().prefix(3) {
        case "dev":
            self.environment = .dev
            baseURL = CNINetworkConstants.devBaseURL
        case "sta":
            self.environment = .staging
            baseURL = CNINetworkConstants.stagingBaseURL
        case "pro":
            self.environment = .production
            baseURL = CNINetworkConstants.productionBaseURL
        default:
            self.environment = .unknowEnvironment
            baseURL = CNINetworkConstants.devBaseURL
        }

        super.init()
    }

    func protocolVersion() -> String {
        return CNINetworkConfiguration.protocolVersion
    }
}
