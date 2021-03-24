//
//  OpenSkyNetworkTests.swift
//  
//
//  Created by Van Simmons on 3/22/21.
//

import Foundation
import XCTest
@testable import OpenSkyNetwork

final class APITests: XCTestCase {
    static var allTests = [
        ("testApiCall", testApiCall)
    ]

    let session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate: nil,
        delegateQueue: nil
    )

    override class func setUp() { }

    func testApiCall() {
        let expectation = XCTestExpectation(description: "ApiCall")
        let cancellable = API.fetch(session: session, boundingBox: Locations.bna.twoDegreeBoundingBox)
            .sink { completion in
                switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let failure):
                        XCTFail("Failed with: \(failure)")
                }
            } receiveValue: { data in
                print("Received records on \(data.aircraftStates.count) aircraft")
                expectation.fulfill()
            }
        let result = XCTWaiter.wait(for: [expectation], timeout: 10.0)
        guard result == .completed else {
            cancellable.cancel()
            XCTFail("Timed out")
            return
        }
    }
}
