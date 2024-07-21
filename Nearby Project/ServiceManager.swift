//
//  NearbyServiceManager.swift
//  NearbyService
//
//  Created by irfan  Afifi on 15/02/24.
//

import Foundation

import NearbyConnections
import AppKit

//class DeviceModel{
//var id: String;
//    var
//}

 class ServiceManager :  NSObject, ObservableObject {
  let connectionManager: ConnectionManager
    let advertiser: Advertiser
    let discoverer: Discoverer
     
     @Published private(set) var discoverDevices: [DiscoverDevice] = []
     @Published private(set) var conRequests: [ConnectionRequest] = []
     @Published private(set) var connectedEndpoints: [ConnectedEndpoint] = []
     @Published private(set) var phoneStatus: PhoneStatus? = nil

  override init() {
      
    connectionManager = ConnectionManager(serviceID: "NearbySharing", strategy: .cluster)
    
      
      advertiser = Advertiser(connectionManager: connectionManager)
          

          // The endpoint info can be used to provide arbitrary information to the
          // discovering device (e.g. device name or type).
          
      discoverer = Discoverer(connectionManager: connectionManager)
      

  }
     
     private static func generateEndpointID()->[UInt8]{
         var id:[UInt8]=[]
         let alphabet="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".compactMap {UInt8($0.asciiValue!)}
         for _ in 0...3{
             id.append(alphabet[Int.random(in: 0..<alphabet.count)])
         }
         return id
     }
     
    func startDiscover() {
        connectionManager.delegate = self
        discoverer.delegate = self
        
        discoverer.startDiscovery()
    }
     
     func startAdvertiser(){
         connectionManager.delegate = self
         advertiser.delegate = self
         advertiser.startAdvertising(using: Host.current().localizedName?.data(using: .utf8) ?? "Unknown".data(using: .utf8)!){err in
             print("error \(err)")
             
         }
     }
     
     func stopAdvertiser(){
         advertiser.stopAdvertising()
         conRequests.removeAll()
         connectedEndpoints.removeAll() 
     }
     
     func requestConnect(device: DiscoverDevice){
         print("Request Connect")
         discoverer.requestConnection(to: device.endpointID, using: "Macbook".data(using: .utf8)!)
     }
     
     func sendText(to endpoints: [EndpointID],value: String){
         print("Send text")
         let payloadId = PayloadID.unique()
         let token = connectionManager.send((value.data(using: .utf8))!, to: endpoints, id: payloadId)
//         let url = URL(filePath: "/Users/irfanafifi/Downloads/android-studio-2023.1.1.28-mac_arm.dmg")
//         let stream = try! InputStream(url: url )
//         if(stream != nil){
//             let start = connectionManager.startStream(stream!, to: endpoints)
//         }
         
         
         let payload = Payload(id: payloadId, type: .bytes, status: .inProgress(Progress()), isIncoming: false, cancellationToken: token)
         for endpoint in endpoints {
             guard let index = connectedEndpoints.firstIndex(where: {$0.endpointID == endpoint})else{
                 return
             }
             connectedEndpoints[index].payload.insert(payload, at: 0)
             print("Success send text on \(connectedEndpoints[index])")
         }
         
     }
}

extension ServiceManager: ConnectionManagerDelegate {
   func connectionManager(
    _ connectionManager: ConnectionManager, didReceive verificationCode: String,
    from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
    // Optionally show the user the verification code. Your app should call this handler
    // with a value of `true` if the nearby endpoint should be trusted, or `false`
    // otherwise.
        print("Connection Request")
        guard let index = discoverDevices.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        let endpoint = discoverDevices.remove(at: index)
        let request = ConnectionRequest(
            id: endpoint.id,
            endpointID: endpointID,
            endpointName:  endpoint.name,
            pin: verificationCode,
            shouldAccept: { accept in
                verificationHandler(accept)
            }
        )
        conRequests.insert(request, at: 0)
    
  }

   func connectionManager(
    _ connectionManager: ConnectionManager, didReceive data: Data,
    withID payloadID: PayloadID, from endpointID: EndpointID) {
        // A simple byte payload has been received. This will always include the full data.
        print("ConnectionManager: Has Receive paylod from \(endpointID)")
        
        
        let jsonString = String(data: data, encoding: .utf8)
        print(jsonString)
        do {
            // Mengurai JSON Data menjadi Dictionary
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // dictionary berisi hasil konversi dari JSON String
                print("succes to Dictionary")
                print(dictionary)
          
        let kind = dictionary["kind"] as! String
                
                let decoder = JSONDecoder()
        
                if(kind == "update" && phoneStatus != nil){
                    
                    guard let newPhoneModel = try? decoder.decode(PhoneStatus.self, from: data) else{return}
                    
                    let copyData = phoneStatus!.copyWith(
                        battery_level: newPhoneModel.battery_level,
                        isCharging: newPhoneModel.isCharging,
                        signalLength: newPhoneModel.signalLength
                    )
                    phoneStatus = copyData
                    print("update")
                    
                }else if(kind == "initial"){
                    
                
        
        guard var phoneModel = try? decoder.decode(PhoneStatus.self, from: data) else{return}
        let batteryLevelParse = Int(phoneModel.battery_level ?? "0") ?? 0
        var batteryIcon = ""
        switch batteryLevelParse {
        case let x where x > 75:
            
            batteryIcon = "battery.\(100)percent"
            break
        case let x where x <= 75:
            
            batteryIcon = "battery.\(75)percent"
            break
        case let x where x <= 50:
            
            batteryIcon = "battery.\(50)percent"
            break
        case let x where x <= 25:
            
            batteryIcon = "battery.\(25)percent"
            break
        default:
            break
        }
        
        phoneModel.batteryIcon = batteryIcon
        phoneModel.endpointID = endpointID
        phoneStatus = phoneModel
        print(phoneModel.battery_level)
            }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
//        print(String(data: data, encoding: .utf8))
//        let payload = Payload(
//            id: payloadID,
//            type: .bytes,
//            status: .success,
//            isIncoming: true,
//            cancellationToken: nil
//        )
//        guard let index = connectedEndpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
//            return
//        }
//        connectedEndpoints[index].payload.insert(payload, at: 0)
        
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
        print("Connecting")
        break
      // A connection to the remote endpoint is currently being established.
    case .connected:
        print("Connected")
        guard let index = conRequests.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        let request = conRequests.remove(at: index)
        let connection = ConnectedEndpoint(
            id: request.id,
            endpointID: endpointID,
            name: request.endpointName
        )
        connectedEndpoints.insert(connection, at: 0)
        
        print("ConnectedEndpoints \(connectedEndpoints)")
        
      // We're connected! Can now start sending and receiving data.
    case .disconnected:
        print("Disconnect")
        guard let index = connectedEndpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connectedEndpoints.remove(at: index)
        phoneStatus = nil
      // We've been disconnected from this endpoint. No more data can be sent or received.
    case .rejected:
        print("Rejected")
        guard let index = conRequests.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        conRequests.remove(at: index)
      // The connection was rejected by one or both sides.
    
    }
  }
//    func connectionManager(
//        _ connectionManager: ConnectionManager, didReceive verificationCode: String,
//        from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
//        // Optionally show the user the verification code. Your app should call this handler
//        // with a value of `true` if the nearby endpoint should be trusted, or `false`
//        // otherwise.
//        verificationHandler(true)
//      }
}


extension ServiceManager: AdvertiserDelegate {
     func advertiser(
    _ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID,
    with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
    // Accept or reject any incoming connection requests. The connection will still need to
    // be verified in the connection manager delegate.
        guard let name = String(data: context, encoding: .utf8) else{return}
        print("Request Connect : \(name)")
        let endpoint = DiscoverDevice(id: UUID(), endpointID: endpointID, name: name)
        discoverDevices.insert(endpoint, at: 0)
        connectionRequestHandler(true)
//        print("Accepr or reject")
//        let alert = NSAlert()
//        alert.messageText = "Confirmation"
//        alert.informativeText = "Device Will be Connect :\nEndpointID : \(endpointID)"
//        alert.addButton(withTitle: "Accept")
//        alert.addButton(withTitle: "Decline")
        
//        let response = alert.runModal()
//        switch response {
//        case .alertFirstButtonReturn:
//            connectionRequestHandler(true)
//            break
//        case .alertSecondButtonReturn:
//            connectionRequestHandler(false)
//            
//            break
//        default:
//            break
//        }
//        alert.window.close()
        
    
  }
//    func advertiser(
//        _ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID,
//        with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
//        // Call with `true` to accept or `false` to reject the incoming connection request.
//        connectionRequestHandler(true)
//      }
}


extension ServiceManager: DiscovererDelegate {
     func discoverer(
    _ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
    // An endpoint was found.
        guard let name = String(data: context, encoding: .utf8) else {return}
        print("Found Endpoint")
        print(discoverer.connectionManager.serviceID)
        print(endpointID)
        print(name)
        let deviceModel = DiscoverDevice(id: UUID(),endpointID: endpointID, name: name)
        discoverDevices.insert(deviceModel, at: 0)
        print("discoverDevices : \(discoverDevices)")
  }

     func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
    // A previously discovered endpoint has gone away.
         print("EndointLost : \(endpointID)")
         discoverDevices.removeAll{$0.endpointID == endpointID}
         print(discoverDevices)
  }
}
