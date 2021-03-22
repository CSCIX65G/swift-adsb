//
//  File.swift
//  
//
//  Created by Van Simmons on 3/21/21.
//

import Logging
import Combine
import Foundation

public struct GeoLocation {
    public let lat: Double
    public let lon: Double

    public var twoDegreeBoundingBox: BoundingBox {
        .init(
            lowerLeft: .init(lat: lat - 1.0, lon: lon - 1.0),
            upperRight: .init(lat: lat + 1.0, lon: lon + 1.0)
        )
    }
}

public struct BoundingBox {
    public let lowerLeft: GeoLocation
    public let upperRight: GeoLocation
    public var openskyUrl: URL {
        .init(
            string:
                "https://rvsrvs:Asdfghj1$@opensky-network.org/api/states/all?lamin= \(lowerLeft.lat)&lomin=\(lowerLeft.lon)&lamax=\(upperRight.lat)&lomax=\(upperRight.lon)"
        )!
    }
}

public struct Locations {
    public static var bna: GeoLocation = .init(lat: 36.131687, lon: -86.668823)
    public static var dulles: GeoLocation = .init(lat: 38.9400586, lon: -77.4684582)
}

enum OpenSkyError: Error, CustomStringConvertible {
    case networkError(Error)
    case invalidURLString(String)
    case emptyURLResponse
    case invalidURLResponse(URLResponse)
    case invalidHTTPURLResponse(Int)
    case noData

    var description: String {
        switch self {
            case let .networkError(error):
                return "Error: FutureError.networkError(\(error))"
            case .invalidURLString(let badString):
                return "Error: FutureError.invalidURLString(\(badString))"
            case .emptyURLResponse:
                return "Error: Empty URLResponse"
            case .invalidURLResponse(let urlResponse):
                return "Error: Response not appropriate - \(urlResponse)"
            case .invalidHTTPURLResponse(let code):
                return "Error: Invalid URL Response: \(code)"
            case .noData:
                return "Error: No data returned from URL"
        }
    }
}

let session = URLSession(
    configuration: URLSessionConfiguration.default,
    delegate: nil,
    delegateQueue: nil
)

func fetch(url: URL) -> AnyPublisher<Data, OpenSkyError> {
    let publisher = session.dataTaskPublisher(for: url)
        .tryMap { (data: Data, response: URLResponse) -> Data in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenSkyError.invalidURLResponse(response)
            }
            guard httpResponse.statusCode / 100 == 2 else {
                throw OpenSkyError.invalidHTTPURLResponse(httpResponse.statusCode)
            }
            guard data.count > 0 else {
                throw OpenSkyError.noData
            }
            return data
        }
        .mapError { error -> OpenSkyError in
            guard let error = error as? OpenSkyError else {
                return OpenSkyError.networkError(error)
            }
            return error
        }
        .eraseToAnyPublisher()
    return publisher
}

//public struct API {
//    public static func //publisher(for boundingBox: BoundingBox)
//}
