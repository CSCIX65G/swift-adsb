//
//  ParsingTests.swift
//  
//
//  Created by Van Simmons on 3/24/21.
//

import Foundation
import XCTest
@testable import OpenSkyNetwork

final class ParsingTests: XCTestCase {
    static var allTests = [
        ("testSingleSquawkDecode", testSingleSquawkDecode),
        ("testApiParsing", testApiParsing)
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

    func testSingleSquawkDecode() {
        let fm = FileManager.default

        XCTAssertNotNil(Self.singleAircraftPath)
        let localPath = Self.singleAircraftPath!
        XCTAssertTrue(fm.fileExists(atPath: localPath), "File not found")

        let url = URL(fileURLWithPath: localPath)
        XCTAssertNoThrow(try Data.init(contentsOf: url), "Could not read file")

        let data = try! Data.init(contentsOf: url)
        XCTAssertNoThrow(try JSONDecoder().decode(RawAircraftState.self, from: data), "Not JSON")

        let rawState = try! JSONDecoder().decode(RawAircraftState.self, from: data)
        XCTAssertEqual(rawState.icao24, "a234d7", "Bad ICAO24")
        XCTAssertEqual(rawState.position_source, 0, "Bad position source")
        XCTAssertTrue(rawState.isValid, "Invalid raw state")

        guard let state = AircraftState.init(from: rawState) else {
            XCTFail("Could not process raw state")
            return
        }
        XCTAssertNotNil(state, "Could not parse")
        XCTAssertEqual(state.icao, "a234d7", "Incorrect ICAO")
        XCTAssertEqual(state.callSign, "N241MP  ", "Incorrect call sign")
        XCTAssertEqual(state.originCountry, "United States", "Incorrect origin country")
        XCTAssertEqual(
            state.timeStamp,
            Date(timeIntervalSince1970: TimeInterval(1616352646)),
            "Incorrect time stamp"
        )
        XCTAssertEqual(state.lon, -87.2947, "Incorrect longitude")
        XCTAssertEqual(state.lat, 36.5803, "Incorrect latitude")
        XCTAssertEqual(state.onGround, false, "Incorrect on ground indicator")
        XCTAssertEqual(state.velocity, 55.56, "Incorrect velocity")
        XCTAssertEqual(state.trueTrack, 89.47, "Incorrect true track")
        XCTAssertEqual(state.ascentRate, 0.0, "Incorrect ascent rate")
        XCTAssertEqual(state.altitude, 1661.16, "Incorrect geometric altitude")
    }

    func testApiParsing() {
        let fm = FileManager.default

        XCTAssertNotNil(Self.bnaPath)
        let localPath = Self.bnaPath!
        XCTAssertTrue(fm.fileExists(atPath: localPath), "File not found")

        let url = URL(fileURLWithPath: localPath)
        XCTAssertNoThrow(try Data.init(contentsOf: url), "Could not read file")

        let data = try! Data.init(contentsOf: url)
        XCTAssertNoThrow(try JSONDecoder().decode(AircraftStateBatch.self, from: data), "Not JSON")

        let batch = try! JSONDecoder().decode(AircraftStateBatch.self, from: data)
        XCTAssertEqual(batch.aircraftStates.count, 51, "Incomplete parse")
    }
}
