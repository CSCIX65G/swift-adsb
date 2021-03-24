//
//  File.swift
//  
//
//  Created by Van Simmons on 3/23/21.
//

public struct GeoLocation {
    public let lat: Double
    public let lon: Double

    public var twoDegreeBoundingBox: GeoBoundingBox {
        .init(
            lowerLeft: .init(lat: max(lat - 1.0, -90.0), lon: max(lon - 1.0, -180.0)),
            upperRight: .init(lat: min(lat + 1.0, 90.0), lon: min(lon + 1.0, 180.0))
        )
    }
}

public struct GeoBoundingBox {
    public let lowerLeft: GeoLocation
    public let upperRight: GeoLocation
}

public struct Locations {
    public static var bna: GeoLocation = .init(lat: 36.131687, lon: -86.668823)
    public static var iad: GeoLocation = .init(lat: 38.9400586, lon: -77.4684582)
}
