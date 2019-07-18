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
            print("Are you sure you provided the apiToken?")
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

    func httpMethodString() -> String {
        switch self {
        case .get:
            return "GET"
        case .delete(_):
            return "DELETE"
        case .post(_):
            return "POST"
        }
    }
    
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

public typealias completionClosure<T> = (_ response: CNIResponse<T>) -> Void

class CNIRequestManager: NSObject {
    let urlSession: URLSession
    let networkConfiguration: CNINetworkConfiguration
    var tasks = [Any]()
    
    init(environment: CNIEnvironment,
         token: String,
         isTesting: Bool) {
        let config = URLSessionConfiguration.default
        networkConfiguration = CNINetworkConfiguration(token: token,
                                                       environment: environment)
        config.httpAdditionalHeaders = ["X-Authorization" : networkConfiguration.token,
                                        "X-Protocol-Version": networkConfiguration.protocolVersion(),
                                        "X-Test": isTesting]
        urlSession = URLSession(configuration: config)
        super.init()
        
    }
    
    func request(endpoint: String, method: HttpMethod = .get, source: String) -> URLRequest? {
        let urlString = networkConfiguration.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(source, forHTTPHeaderField: "X-Source")
        request.httpMethod = method.httpMethodString()
        switch method {
        case let .post(params), let .delete(params):
            let postData: Data
            if #available(iOS 11.0, *) {
                postData = try! JSONSerialization.data(withJSONObject: params, options: .sortedKeys)
            } else {
                // Fallback on earlier versions
                postData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            request.httpBody = postData
        default:
            break
        }
        return request
    }
    
    func task(with urlRequest: URLRequest, urlSession: URLSession, completion: @escaping completionClosure<Data>) {
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(CNIResponse(result: nil, error: error, isSuccessful: false))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                debugPrint("response is not a http response")
                return
            }
            if httpResponse.statusCode < 300, let data = data {
                completion(CNIResponse(result: data, error: nil, isSuccessful: true))
            } else {
                let error = CNIRequestManager.errorStatusCodeHandler(httpResponse.statusCode)
                completion(CNIResponse(result: data, error: error, isSuccessful: false))
            }
        }
        task.resume()
        tasks.append(task)
    }
    
    func requestAction(endpoint: String,
                              method: HttpMethod,
                              source: String,
                              completion: @escaping completionClosure<Data>) {
        guard let request = request(endpoint: endpoint, method: method, source: source) else {
            assertionFailure("request format error")
            return
        }
        task(with: request, urlSession: self.urlSession, completion: completion)
    }
    
    // MARK: - Helpers
    
    private static func errorStatusCodeHandler(_ code: Int) -> Error {
        if code >= 300 {
            return CNIHttpError.fromError(code: code)
        } else {
            return CNIHttpError.unknownError
        }
    }
}
