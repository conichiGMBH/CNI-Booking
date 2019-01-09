//
//  CNIRequestManager.swift
//  conichi-ios-itinerary
//
//  Created by Vincent Jacquesson on 3/14/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import UIKit

enum CNIHttpError: Error {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case requestTimeout
    case unknownError
    
    static func fromError(code: Int) -> Error {
        switch code {
        case 400:
            return CNIHttpError.badRequest
        case 401:
            print("Are you sure you added the following keys to your info.plist: CNICONFIGURATIONUSERNAME, CNICONFIGURATIONPASSWORD, CNICONFIGURATIONCONSUMERKEY, CNICONFIGURATIONENVIRONMENT, check the README on github")
            return CNIHttpError.unauthorized
        case 403:
            return CNIHttpError.forbidden
        case 404:
            return CNIHttpError.notFound
        case 408:
            return CNIHttpError.requestTimeout
        default:
            return CNIHttpError.unknownError
        }
    }
}

enum HttpMethod: Equatable {
    case get
    case post([String: Any])
    case delete([String: Any])
    
    // This is mainly for Nimble and testing
    static func == (lhs: HttpMethod, rhs: HttpMethod) -> Bool {
        switch (lhs, rhs) {
        case (.get, .get): return true
        case let (.post(l), .post(r)): return l.count == r.count
        case let (.delete(l), .delete(r)): return l.count == r.count
        case (.get, _),
             (.post, _),
             (.delete, _): return false
        }
    }
}

public typealias successClosure<T> = (_ results: T) -> Void
public typealias failureClosure = (_ error: Error) -> Void


class CNIRequestManager: NSObject {
    let urlSession: URLSession
    let networkConfiguration: CNINetworkConfiguration
    var tasks = [Any]()
    
    init(username: String!,
         password: String!,
         consumerKey: String!,
         environment: String!) {
        let config = URLSessionConfiguration.default
        networkConfiguration = CNINetworkConfiguration(username: username,
                                                       password: password,
                                                       consumerKey: consumerKey,
                                                       environment: environment)
        config.httpAdditionalHeaders = ["Authorization" : networkConfiguration.authString,
                                        "X-Consumer-Key": networkConfiguration.consumerKey]
        urlSession = URLSession(configuration: config)
        super.init()
        
    }
    
    public func request(endpoint: String, method: HttpMethod = .get) -> URLRequest? {
        let urlString = networkConfiguration.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        switch method {
        case .get:
            request.httpMethod = "GET"
        case let .post(params), let .delete(params):
            let postData: Data
            if #available(iOS 11.0, *) {
                postData = try! JSONSerialization.data(withJSONObject: params, options: .sortedKeys)
            } else {
                // Fallback on earlier versions
                postData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            request.httpBody = postData
            if case .post = method {
                request.httpMethod = "POST"
            } else {
                request.httpMethod = "DELETE"
            }
        }
        return request
    }
    
    public func task(with urlRequest: URLRequest, urlSession: URLSession, success: @escaping successClosure<Data>, failure: @escaping failureClosure) {
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            if let error = error {
                failure(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                assertionFailure("not a http response")
                return
            }
            if httpResponse.statusCode < 300, let data = data {
                success(data)
            } else if let error = self?.errorStatusCodeHandler(httpResponse.statusCode) {
                failure(error)
            } else {
                assertionFailure("error isn't generated")
                return
            }
        }
        task.resume()
        tasks.append(task)
    }
    
    public func requestAction(endpoint: String,
                              method: HttpMethod,
                              success: @escaping successClosure<Data>,
                              failure: @escaping failureClosure) {
        guard let request = request(endpoint: endpoint, method: method) else {
            assertionFailure("request format error")
            return
        }
        task(with: request, urlSession: self.urlSession, success: success, failure: failure)
    }
    
    // MARK: - Helpers
    
    private func errorStatusCodeHandler(_ code: Int) -> Error {
        if code >= 300 {
            return CNIHttpError.fromError(code: code)
        } else {
            return CNIHttpError.unknownError
        }
    }
}
