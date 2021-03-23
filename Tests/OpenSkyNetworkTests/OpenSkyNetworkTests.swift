//
//  OpenSkyNetworkTests.swift
//  
//
//  Created by Van Simmons on 3/22/21.
//

import Foundation
import XCTest
@testable import OpenSkyNetwork

final class OpenSkyNetworkTests: XCTestCase {
    let session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate: nil,
        delegateQueue: nil
    )

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testApiCall() {
        let expectation = XCTestExpectation(description: "ApiCall")
        let url = Locations.bna.twoDegreeBoundingBox.openskyUrl
        let cancellable = API.fetch(session: session, url: url)
            .sink { completion in
                switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let failure):
                        XCTFail("Failed with: \(failure)")
                }
            } receiveValue: { data in
                expectation.fulfill()
            }
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        guard result == .completed else {
            cancellable.cancel()
            XCTFail("Timed out")
            return
        }
    }

    static var allTests = [
        ("testApiCall", testApiCall),
    ]
}
