//
//  File.swift
//  
//
//  Created by Van Simmons on 3/21/21.
//

import Logging
import Combine
import Foundation

extension GeoBoundingBox {
    public var openskyUrl: URL {
        let lllat = "\(lowerLeft.lat)"
        let lllon = "\(lowerLeft.lon)"
        let urlat = "\(upperRight.lat)"
        let urlon = "\(upperRight.lon)"
        let urlString = "https://opensky-network.org/api/states/all?lamin=\(lllat)&lomin=\(lllon)&lamax=\(urlat)&lomax=\(urlon)"
        return .init(string: urlString)!
    }
}

public enum APIError: Error, CustomStringConvertible {
    case networkError(Error)
    case invalidURLString(String)
    case emptyURLResponse
    case invalidURLResponse(URLResponse)
    case invalidHTTPURLResponse(Int)
    case noData
    case decodingError(Error)

    public var description: String {
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
            case .decodingError(let error):
                return "Error decoding: \(error)"
        }
    }
}

public struct API {
    static let decoder = JSONDecoder()

    static func fetch(session: URLSession, url: URL) -> AnyPublisher<Data, APIError> {
        session.dataTaskPublisher(for: url)
            .tryMap { (data: Data, response: URLResponse) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidURLResponse(response)
                }
                guard httpResponse.statusCode / 100 == 2 else {
                    throw APIError.invalidHTTPURLResponse(httpResponse.statusCode)
                }
                guard data.count > 0 else {
                    throw APIError.noData
                }
                return data
            }
            .mapError { error -> APIError in
                guard let error = error as? APIError else {
                    return APIError.networkError(error)
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    public static func fetch(session: URLSession, boundingBox: GeoBoundingBox) -> AnyPublisher<AircraftStateBatch, APIError> {
        fetch(session: session, url: boundingBox.openskyUrl)
            .decode(type: AircraftStateBatch.self, decoder: decoder)
            .mapError { APIError.decodingError($0) }
            .eraseToAnyPublisher()
    }
}
