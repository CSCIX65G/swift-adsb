//
//  File.swift
//  
//
//  Created by Van Simmons on 3/21/21.
//

import Foundation

/*:
 Model of the API from: https://opensky-network.org/apidoc/rest.html

icao24          string  Unique ICAO 24-bit address of the transponder in hex string representation.
callsign        string  Callsign of the vehicle (8 chars). Can be null if no callsign has been ved.
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

struct RawAircraftState {
    let icao24: String
    let callsign: String?
    let origin_country: String
    let time_position: Int?
    let last_contact: Int
    let longitude: Double?
    let latitude: Double?
    let baro_altitude: Double?
    let on_ground: Bool
    let velocity: Double?
    let true_track: Double?
    let vertical_rate: Double?
    let sensors: [Int]?
    let geo_altitude: Double?
    let squawk: String?
    let spi: Bool
    let position_source: Int
}

struct AircraftState {
    let icao: String
    let callSign: String?
    let originCountry: String
    let timeStamp: Int?
    let lastContact: Int
    let lon: Double?
    let lat: Double?
    let barometricAltitude: Double?
    let onGround: Bool
    let velocity: Double?
    let trueTrack: Double?
    let ascentRate: Double?
    let sensors: [Int]?
    let geometricAltitude: Double?
    let squawk: String?
    let specialPurposeIndicator: Bool
    let positionSource: Int
}

extension AircraftState: Codable, Identifiable {
    var id: String { "\(icao):\(timeStamp ?? Int.max)" }
}
