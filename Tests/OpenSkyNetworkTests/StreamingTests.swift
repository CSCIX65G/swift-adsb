//
//  StreamingTests.swift
//  
//
//  Created by Van Simmons on 3/24/21.
//

import Foundation
import XCTest
@testable import OpenSkyNetwork

final class StreamingTests: XCTestCase {
    static var allTests = [
        ("testStream", testStream)
    ]

    static var resourceBundle: Bundle = Bundle.module
    static var singleAircraftPath: String!
    static var bnaPath: String!

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

    override func tearDownWithError() throws { }

    func testStream() {
    }

}
