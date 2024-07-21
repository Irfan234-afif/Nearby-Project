//
//  NearbyServiceManager.swift
//  NearbyService
//
//  Created by irfan  Afifi on 15/02/24.
//

import Foundation
import NearbyConnections

class Example {
  let connectionManager: ConnectionManager
    let advertiser: Advertiser
    let discoverer: Discoverer

  init() {
    connectionManager = ConnectionManager(serviceID: "com.Nearby-Project", strategy: .cluster)
    connectionManager.delegate = self
      
      advertiser = Advertiser(connectionManager: connectionManager)
          advertiser.delegate = self

          // The endpoint info can be used to provide arbitrary information to the
          // discovering device (e.g. device name or type).
          advertiser.startAdvertising(using: "Macbook Air M1".data(using: .utf8)!)
      discoverer = Discoverer(connectionManager: connectionManager)
          discoverer.delegate = self

  }
    func startDiscover() {
        
        discoverer.startDiscovery()
    }
}

extension Example: ConnectionManagerDelegate {
  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive verificationCode: String,
    from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
    // Optionally show the user the verification code. Your app should call this handler
    // with a value of `true` if the nearby endpoint should be trusted, or `false`
    // otherwise.
    verificationHandler(true)
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive data: Data,
    withID payloadID: PayloadID, from endpointID: EndpointID) {
    // A simple byte payload has been received. This will always include the full data.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive stream: InputStream,
    withID payloadID: PayloadID, from endpointID: EndpointID,
    cancellationToken token: CancellationToken) {
    // We have received a readable stream.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager,
    didStartReceivingResourceWithID payloadID: PayloadID,
    from endpointID: EndpointID, at localURL: URL,
    withName name: String, cancellationToken token: CancellationToken) {
    // We have started receiving a file. We will receive a separate transfer update
    // event when complete.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager,
    didReceiveTransferUpdate update: TransferUpdate,
    from endpointID: EndpointID, forPayload payloadID: PayloadID) {
    // A success, failure, cancelation or progress update.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didChangeTo state: ConnectionState,
    for endpointID: EndpointID) {
    switch state {
    case .connecting:
      // A connection to the remote endpoint is currently being established.
    case .connected:
      // We're connected! Can now start sending and receiving data.
    case .disconnected:
      // We've been disconnected from this endpoint. No more data can be sent or received.
    case .rejected:
      // The connection was rejected by one or both sides.
    }
  }
    func connectionManager(
        _ connectionManager: ConnectionManager, didReceive verificationCode: String,
        from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
        // Optionally show the user the verification code. Your app should call this handler
        // with a value of `true` if the nearby endpoint should be trusted, or `false`
        // otherwise.
        verificationHandler(true)
      }
}


extension Example: AdvertiserDelegate {
  func advertiser(
    _ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID,
    with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
    // Accept or reject any incoming connection requests. The connection will still need to
    // be verified in the connection manager delegate.
    connectionRequestHandler(true)
  }
    func advertiser(
        _ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID,
        with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
        // Call with `true` to accept or `false` to reject the incoming connection request.
        connectionRequestHandler(true)
      }
}


extension Example: DiscovererDelegate {
  func discoverer(
    _ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
    // An endpoint was found.
  }

  func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
    // A previously discovered endpoint has gone away.
  }
}
