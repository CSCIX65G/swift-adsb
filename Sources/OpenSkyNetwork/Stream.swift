//
//  Stream.swift
//  
//
//  Created by Van Simmons on 3/24/21.
//

class OpenSkyStream {
    
}

extension OpenSkyStream {
    enum Element {
        case insert(AircraftState)
        case update(current: AircraftState, previous: AircraftState)
        case delete(AircraftState)
    }
}
