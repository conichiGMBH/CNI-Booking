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
    let subject = CNIRequestManager(environment: .staging, token: "token", isTesting: true)

    override func spec() {
        describe(".init") {
            it("sets X-Protocol-Version in headers") {
                let protocolVersion = self.subject.urlSession.configuration.httpAdditionalHeaders?["X-Protocol-Version"] as? String
                expect(protocolVersion).to(equal(CNINetworkConfiguration.protocolVersion))
            }

            it("sets token as X-Authorization header"){
                let token = self.subject.urlSession.configuration.httpAdditionalHeaders?["X-Authorization"] as? String
                expect(token).to(equal("token"))
            }

            it("sets X-Test header") {
                let test = self.subject.urlSession.configuration.httpAdditionalHeaders?["X-Test"] as? Bool
                expect(test).to(equal(true))
            }
        }

        describe(".task") {
            var mockURLSession: MockURLSession!
            
            beforeEach {
                mockURLSession = MockURLSession()
            }
            
            context("when there's an error") {
                it("passes the error by failure closure") {
                    var response: CNIResponse<Data>!
                    let expectedError = NSError(domain: "com.conichi.error", code: 123, userInfo: [:])
                    mockURLSession.error = expectedError

                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, completion: {
                        (r: CNIResponse<Data>) in
                        response = r
                    })

                    expect(response.isSuccessful).toEventually(beFalse())
                    expect(response.error).toEventually(matchError(expectedError))
                    expect(response.result).toEventually(beNil())
                }
            }
            
            context("when response isn't a HTTPURLResponse") {
                it("returns and doesn't call callbacks") {
                    var completionCalled = false

                    mockURLSession.response = URLResponse(url: URL(string: "url")!, mimeType: "application/json", expectedContentLength: 10, textEncodingName: nil)

                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, completion: {
                        _ in
                        completionCalled = true
                    })

                    expect(completionCalled).to(beFalse())
                }
            }
            
            context("when status code of response is smaller than 300") {
                it("calls completion handler with CNIResponse containing the data") {
                    var response: CNIResponse<Data>!
                    let expectedData = Data(bytes: [0, 1, 0, 1])
                    mockURLSession.data = expectedData
                    mockURLSession.response = HTTPURLResponse(url: URL(string: "url")!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: [:])

                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, completion: {
                        (r: CNIResponse<Data>) in
                        response = r
                    })

                    expect(response.isSuccessful).toEventually(beTrue())
                    expect(response.error).toEventually(beNil())
                    expect(response.result).toEventually(equal(expectedData))
                }
            }
            
            context("when status code of response is equal or more than 300") {
                it("passed an the corresponding error by failure closure") {
                    var response: CNIResponse<Data>!

                    let expectedError = CNIHttpError.badRequest
                    let expectedData = Data(bytes: [0, 1, 0, 1])
                    mockURLSession.data = expectedData
                    mockURLSession.response = HTTPURLResponse(url: URL(string: "url")!, statusCode: 400, httpVersion: "HTTP/2.0", headerFields: [:])

                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, completion: {
                        (r: CNIResponse<Data>) in
                        response = r
                    })

                    expect(response.result).toEventually(equal(expectedData))
                    expect(response.isSuccessful).toEventually(beFalse())
                    expect(response.error).toEventually(matchError(expectedError))
                }
            }
            
            context("when status code of response is less than 300 but there's no data given") {
                it("passed an the corresponding error by failure closure") {
                    var response: CNIResponse<Data>!

                    let expectedError = CNIHttpError.unknownError
                    mockURLSession.response = HTTPURLResponse(url: URL(string: "url")!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: [:])

                    self.subject.task(with: URLRequest(url: URL(string: "url")!), urlSession: mockURLSession, completion: {
                        (r: CNIResponse<Data>) in
                        response = r
                    })
                    expect(response.error).toEventually(matchError(expectedError))
                    expect(response.isSuccessful).toEventually(beFalse())
                    expect(response.result).toEventually(beNil())
                }
            }
        }
        
        describe(".request") {
            context("when doing snapshot testing") {
                it("should match previous recorded raw data") {
                    assertSnapshot(
                        matching: self.subject.request(endpoint: CNIBookingConstants.bookingEndpoint, source: "")!,
                        as: .raw
                    )
                    // This will break before iOS 11 because JSON's order can't be maintained and the diff will fail
                    if #available(iOS 11.0, *) {
                        assertSnapshot(
                            matching: self.subject.request(endpoint: CNIBookingConstants.bookingEndpoint, method: .post(["test1": "1 is tested", "test2": "2 is tested", "test3": ["test4": "test 3 & 4 are tested"]]), source: "")!,
                            as: .raw
                        )
                        assertSnapshot(
                            matching: self.subject.request(endpoint: CNIBookingConstants.bookingEndpoint, method: .delete(["test1": "1 is tested", "test2": "2 is tested", "test3": ["test4": "test 3 & 4 are tested"]]), source: "")!,
                            as: .raw
                        )
                    }
                }
            }
            
            context("when endpoint is invalid") {
                it("should return nil") {
                    expect(self.subject.request(endpoint: "123 45", source: "")).to(beNil())
                }
            }
        }
        
        describe(".requestAction") {
            context("when the endpoint is invalid") {
                it("throws assertion") {
                    expect(self.subject.requestAction(endpoint: "123 45", method: .get, source: "", completion: { _ in}))
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
