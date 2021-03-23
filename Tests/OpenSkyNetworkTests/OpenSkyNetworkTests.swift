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
    static var allTests = [
        ("testSingleSquawkDecode", testSingleSquawkDecode),
        ("testApiCall", testApiCall)
    ]

    static var resourceBundle: Bundle = Bundle.module
    static var singleAircraftPath: String!
    static var bnaPath: String!

    let session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate: nil,
        delegateQueue: nil
    )

    override class func setUp() {
        singleAircraftPath = resourceBundle.path(
            forResource: "singleAircraft",
            ofType: "json"
        )

        bnaPath = resourceBundle.path(
            forResource: "bna",
            ofType: "json"
        ) 
    }

    override func tearDownWithError() throws {
    }


    func testSingleSquawkDecode() {
        let fm = FileManager.default
        XCTAssertNotNil(Self.singleAircraftPath)
        let localPath = Self.singleAircraftPath!
        XCTAssertTrue(fm.fileExists(atPath: localPath), "File not found")
        let url = URL(fileURLWithPath: localPath)
        XCTAssertNoThrow(try Data.init(contentsOf: url), "Could not read file")
        let data = try! Data.init(contentsOf: url)
        XCTAssertNoThrow(try JSONDecoder().decode(RawAircraftState.self, from: data))
        let rawState = try! JSONDecoder().decode(RawAircraftState.self, from: data)
        XCTAssertEqual(rawState.icao24, "a234d7", "Bad ICAO24")
        XCTAssertEqual(rawState.position_source, 0, "Bad position source")
        XCTAssertTrue(rawState.isValid, "Invalid raw state")
        XCTAssertNotNil(AircraftState.init(from: rawState), "Bad formatting")
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
        let result = XCTWaiter.wait(for: [expectation], timeout: 10.0)
        guard result == .completed else {
            cancellable.cancel()
            XCTFail("Timed out")
            return
        }
    }
}
