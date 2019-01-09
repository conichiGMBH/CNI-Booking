//
//  CNIRequestManagerTests.swift
//  CNI-ItinerariesTests
//
//  Created by Kai-Hong Tseng on 12/20/18.
//  Copyright © 2018 conichi. All rights reserved.
//

import XCTest
import SnapshotTesting
import Quick
import Nimble

@testable import CNI_Itineraries

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    override func resume() {
        closure()
    }
}

class MockURLSession: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let data = self.data
        let response = self.response
        let error = self.error
        return MockURLSessionDataTask {
            completionHandler(data, response, error)
        }
    }
}

final class CNIRequestManagerTests: QuickSpec {
    let subject = CNIRequestManager(username: "test-user", password: "test", consumerKey: "test-key", environment: "Staging")
    
    override func spec() {
        describe(".task") {
            var mockURLSession: MockURLSession!
            
            beforeEach {
                mockURLSession = MockURLSession()
            }
            
            context("when there's an error") {
                it("passes the error by failure closure") {
                    var resultError: NSError!
                    let expectedError = NSError(domain: "com.conichi.error", code: 123, userInfo: [:])
                    mockURLSession.error = expectedError
                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, success: { _ in }, failure: { error in
                        resultError = error as NSError
                    })
                    expect(resultError).to(equal(expectedError))
                }
            }
            
            context("when response isn't a HTTPURLResponse") {
                it("throws assertion") {
                    mockURLSession.response = URLResponse(url: URL(string: "url")!, mimeType: "application/json", expectedContentLength: 10, textEncodingName: nil)
                    expect(self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, success: { _ in }, failure: { _ in }))
                    .to(throwAssertion())
                }
            }
            
            context("when status code of response is smaller than 300") {
                it("passes the data by success closure") {
                    var resultData: Data!
                    let expectedData = Data(bytes: [0, 1, 0, 1])
                    mockURLSession.data = expectedData
                    mockURLSession.response = HTTPURLResponse(url: URL(string: "url")!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: [:])
                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, success: { data in
                        resultData = data
                    }, failure: { _ in })
                    expect(resultData).to(equal(expectedData))
                }
            }
            
            context("when status code of response is equal or more than 300") {
                it("passed an the corresponding error by failure closure") {
                    var resultError: Error!
                    let expectedError = CNIHttpError.badRequest
                    mockURLSession.response = HTTPURLResponse(url: URL(string: "url")!, statusCode: 400, httpVersion: "HTTP/2.0", headerFields: [:])
                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, success: { _ in }, failure: { error in
                        resultError = error
                    })
                    expect(resultError).to(matchError(expectedError))
                }
            }
            
            context("when status code of response is less than 300 but there's no data given") {
                it("passed an the corresponding error by failure closure") {
                    var resultError: Error!
                    let expectedError = CNIHttpError.unknownError
                    mockURLSession.response = HTTPURLResponse(url: URL(string: "url")!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: [:])
                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, success: { _ in }, failure: { error in
                        resultError = error
                    })
                    expect(resultError).to(matchError(expectedError))
                }
            }
        }
        
        describe(".request") {
            context("when doing snapshot testing") {
                it("should match previous recorded raw data") {
                    assertSnapshot(
                        matching: self.subject.request(endpoint: CNIBookingConstants.bookingsEndpoint)!,
                        as: .raw
                    )
                    // This will break before iOS 11 because JSON's order can't be maintained and the diff will fail
                    if #available(iOS 11.0, *) {
                        assertSnapshot(
                            matching: self.subject.request(endpoint: CNIBookingConstants.bookingsEndpoint, method: .post(["test1": "1 is tested", "test2": "2 is tested", "test3": ["test4": "test 3 & 4 are tested"]]))!,
                            as: .raw
                        )
                        assertSnapshot(
                            matching: self.subject.request(endpoint: CNIBookingConstants.bookingsEndpoint, method: .delete(["test1": "1 is tested", "test2": "2 is tested", "test3": ["test4": "test 3 & 4 are tested"]]))!,
                            as: .raw
                        )
                    }
                }
            }
            
            context("when endpoint is invalid") {
                it("should return nil") {
                    expect(self.subject.request(endpoint: "123 45")).to(beNil())
                }
            }
        }
        
        describe(".requestAction") {
            context("when the endpoint is invalid") {
                it("throws assertion") {
                    expect(self.subject.requestAction(endpoint: "123 45", method: .get, success: { _ in }, failure: { _ in }))
                    .to(throwAssertion())
                }
            }
        }
        
        describe(".fromError") {
            context("when status codes is 400") {
                it("returns bad request") {
                    expect(CNIHttpError.fromError(code: 400)).to(matchError(CNIHttpError.badRequest))
                }
            }
            
            context("when status codes is 401") {
                it("returns unauthorized") {
                    expect(CNIHttpError.fromError(code: 401)).to(matchError(CNIHttpError.unauthorized))
                }
            }
            
            context("when status codes is 403") {
                it("returns forbidden") {
                    expect(CNIHttpError.fromError(code: 403)).to(matchError(CNIHttpError.forbidden))
                }
            }
            
            context("when status codes is 404") {
                it("returns forbidden") {
                    expect(CNIHttpError.fromError(code: 404)).to(matchError(CNIHttpError.notFound))
                }
            }
            
            context("when status codes is 408") {
                it("returns request timeout") {
                    expect(CNIHttpError.fromError(code: 408)).to(matchError(CNIHttpError.requestTimeout))
                }
            }
            
            context("when status codes is undefined") {
                it("returns unknown error") {
                    expect(CNIHttpError.fromError(code: 402)).to(matchError(CNIHttpError.unknownError))
                }
            }
        }
    }
}
