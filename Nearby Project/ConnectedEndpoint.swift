//
//  ConnectedEndpoint.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 16/02/24.
//

import Foundation
import NearbyConnections

struct ConnectedEndpoint: Identifiable{
    let id: UUID
    let endpointID: EndpointID
    let name: String
    var payload: [Payload] = []
}
