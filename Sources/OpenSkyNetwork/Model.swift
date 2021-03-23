//
//  File.swift
//  
//
//  Created by Van Simmons on 3/21/21.
//

import Foundation

/*:
 ### Model of the API from: https://opensky-network.org/apidoc/rest.html

icao24          string  Unique ICAO 24-bit address of the transponder in hex string representation.
callsign        string  Callsign of the vehicle (8 chars). Can be null if no callsign has been received.
origin_country  string  Country name inferred from the ICAO 24-bit address.
time_position   int     Unix timestamp (seconds) for the last position update. Can be null if no ion report was  eived by Op ky within the past 15s.
last_contact    int     Unix timestamp (seconds) for the last update in general.
longitude       float   WGS-84 longitude in decimal degrees. Can be null.
latitude        float   WGS-84 latitude in decimal degrees. Can be null.
baro_altitude   float   Barometric altitude in meters. Can be null.
on_ground       boolean Boolean value which indicates if the position was retrieved from a ce position report
velocity        float   Velocity over ground in m/s. Can be null.
true_track      float   True track in decimal degrees clockwise from north (north=0°). Can be
vertical_rate   float   Vertical rate in m/s. A positive value indicates that the airplane is ing, a negative valu ndicates  t it descends. Can be null.
sensors         int[]   IDs of the receivers which contributed to this state vector. Is null if no ring for sensor s used  the request.
geo_altitude    float   Geometric altitude in meters. Can be null.
squawk          string  The transponder code aka Squawk. Can be null.
spi             boolean Whether flight status indicates special purpose indicator.
position_source int     Origin of this state’s position: 0 = ADS-B, 1 = ASTERIX, 2 = MLAT
 */

enum OpenSkyNetworkError: Error {
    case decodingError(Error)
}

public struct RawAircraftState {
    public let icao24: String
    public let callsign: String?
    public let origin_country: String
    public let time_position: Int?
    public let last_contact: Int
    public let longitude: Double?
    public let latitude: Double?
    public let baro_altitude: Double?
    public let on_ground: Bool
    public let velocity: Double?
    public let true_track: Double?
    public let vertical_rate: Double?
    public let sensors: [Int]?
    public let geo_altitude: Double?
    public let squawk: String?
    public let spi: Bool
    public let position_source: Int
}

extension RawAircraftState: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        icao24 = try container.decode(String.self)
        callsign = try container.decode(String?.self)
        origin_country = try container.decode(String.self)
        time_position = try container.decode(Int?.self)
        last_contact = try container.decode(Int.self)
        longitude = try container.decode(Double?.self)
        latitude = try container.decode(Double?.self)
        baro_altitude = try container.decode(Double?.self)
        on_ground = try container.decode(Bool.self)
        velocity = try container.decode(Double?.self)
        true_track = try container.decode(Double?.self)
        vertical_rate = try container.decode(Double?.self)
        sensors = try container.decode([Int]?.self)
        geo_altitude = try container.decode(Double?.self)
        squawk = try container.decode(String?.self)
        spi = try container.decode(Bool.self)
        position_source = try container.decode(Int.self)
    }

    public var isValid: Bool {
        guard .some(callsign) == callsign,
              .some(time_position) == time_position,
              .some(longitude) == longitude,
              .some(latitude) == latitude,
              .some(baro_altitude) == baro_altitude,
              .some(velocity) == velocity,
              .some(true_track) == true_track,
              .some(vertical_rate) == vertical_rate,
              .some(sensors) == sensors,
              .some(geo_altitude) == geo_altitude,
              .some(position_source) == position_source
        else { return false }
        return true
    }
}

public struct AircraftState {
    public let icao: String
    public let callSign: String
    public let originCountry: String
    public let timeStamp: Date
    public let lon: Double
    public let lat: Double
    public let onGround: Bool
    public let velocity: Double
    public let trueTrack: Double
    public let ascentRate: Double?
    public let altitude: Double?

    public init?(from raw: RawAircraftState) {
        guard raw.isValid else { return nil }
        icao = raw.icao24
        callSign = raw.callsign!
        originCountry = raw.origin_country
        timeStamp = Date(timeIntervalSince1970: TimeInterval(raw.time_position!))
        lon = raw.longitude!
        lat = raw.latitude!
        onGround = raw.on_ground
        velocity = raw.velocity!
        trueTrack = raw.true_track!
        ascentRate = raw.vertical_rate
        altitude = raw.geo_altitude ?? raw.baro_altitude
    }
}

extension AircraftState: Codable, Identifiable {
    public var id: String { "\(icao):\(timeStamp)" }
}

struct AircraftStateBatch {
    public var timeStamp: Date
    public var aircraftStates: [AircraftState]
}

extension AircraftStateBatch: Decodable {
    enum CodingKeys: CodingKey {
        case time
        case states
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let time = try container.decode(Int.self, forKey: .time)
        let rawStates = try container.decode([RawAircraftState].self, forKey: .states)

        self.timeStamp = Date(timeIntervalSince1970: TimeInterval(time))
        self.aircraftStates = rawStates.compactMap(AircraftState.init)
    }
}
