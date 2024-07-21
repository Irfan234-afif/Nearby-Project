//
//  ConnectionRequest.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 16/02/24.
//

import Foundation
import NearbyConnections

struct ConnectionRequest: Identifiable {
    let id: UUID
    let endpointID: EndpointID
    let endpointName: String
    let pin: String
    let shouldAccept: ((Bool) -> Void)
}
