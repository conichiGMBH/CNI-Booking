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
    
    public func post(endpoint: String,
                     data: [String: Any],
                     success: @escaping (_ results: Data) -> Void,
                     failure: @escaping (_ error: Error) -> Void) {
        let url = networkConfiguration.baseURL + endpoint
        
        guard let postURL = URL(string: url) else {
            return
        }
        var urlRequest = URLRequest(url: postURL)
        do {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.httpMethod = "POST"
            
            let postData = try JSONSerialization.data(withJSONObject: data, options:.prettyPrinted)
            urlRequest.httpBody = postData
            
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    failure(error)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode < 300 {
                        if let data = data {
                            success(data)
                        }
                    } else if httpResponse.statusCode >= 300 {
                        failure(CNIHttpError.fromError(code: httpResponse.statusCode))
                    }
                }
            }
            task.resume()
            tasks.append(task)
        } catch {
            print("Error formatting json")
        }
    }
    
    public func delete(endpoint: String,
                       data: [String: Any],
                       success: @escaping (_ results: Data) -> Void,
                       failure: @escaping (_ error: Error) -> Void) {
        let url = networkConfiguration.baseURL + endpoint
        
        guard let deleteURL = URL(string: url) else {
            return
        }
        var urlRequest = URLRequest(url: deleteURL)
        do {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.httpMethod = "DELETE"
            
            let postData = try JSONSerialization.data(withJSONObject: data, options:.prettyPrinted)
            urlRequest.httpBody = postData
            
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    failure(error)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode < 300 {
                        if let data = data {
                            success(data)
                        }
                    } else if httpResponse.statusCode >= 300 {
                        failure(CNIHttpError.fromError(code: httpResponse.statusCode))
                    }
                }
            }
            task.resume()
            tasks.append(task)
        } catch {
            print("Error formatting json")
        }
    }
    
    public func get(endpoint: String,
                    success: @escaping (_ results: Data) -> Void,
                    failure: @escaping (_ error: Error) -> Void)
    {
        let url = networkConfiguration.baseURL + endpoint
        
        guard let getURL = URL(string: url) else {
            return
        }
        var urlRequest = URLRequest(url: getURL)
        urlRequest.httpMethod = "GET"
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                failure(error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 300 {
                    if let data = data {
                        success(data)
                    }
                } else if httpResponse.statusCode >= 300 {
                    failure(CNIHttpError.fromError(code: httpResponse.statusCode))
                }
            }
        }
        task.resume()
        tasks.append(task)
    }
}
