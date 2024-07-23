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
    // Fungsi untuk menghasilkan string acak dengan panjang tertentu
    private func randomString(length: Int, pathExtension: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! }) + "." + pathExtension
    }
    
    private func saveFileToDownloads(localURL: URL, fileName: String, fileContents: Data) {
        
        
        var isStale = false
        do {
            let bookmarkData = try localURL.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            let downloadsFolderURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if downloadsFolderURL.startAccessingSecurityScopedResource() {
                defer { downloadsFolderURL.stopAccessingSecurityScopedResource() }
                let fileManager = FileManager.default
                guard let documentDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                    fatalError("Unable to access the document directory.")
                }
                let fileURL = documentDirectory.appendingPathComponent(fileName)
                try fileContents.write(to: fileURL)
                print("File saved to Downloads folder successfully.")
            }
        } catch {
            print("Failed to save file: \(error)")
        }
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
    
    func disconnectDevice(device: ConnectedEndpoint){
        connectionManager.disconnect(from: device.endpointID) {err in
            
        }
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
    
    func sendFile(to endpoints: [EndpointID],url: URL)-> Payload{
        print("File to send : \(url)")
        print("ENDPOINTID : \(endpoints)")
        let payloadId = PayloadID.unique()
        //        do{
        //
        //
        //        let token = connectionManager.send(try Data(contentsOf: url), to: endpoints, id: payloadId)
        //        }catch{
        //
        //            print("ERROR CUY \(error)")
        //        }
        
            
            
            let token =  connectionManager.sendResource(at: url, withName: url.lastPathComponent, to: endpoints, id: payloadId, completionHandler: {err in
                //
                print("KIIRIM FILE ERROR : \(String(describing: err))")
            })
            let payload = Payload(id: payloadId, type: .bytes, status: .inProgress(Progress()), isIncoming: false, cancellationToken: token)
            for endpoint in endpoints {
                guard let index = connectedEndpoints.firstIndex(where: {$0.endpointID == endpoint})else{
                    break
                }
                connectedEndpoints[index].payload.insert(payload, at: 0)
                print("Success send text on \(connectedEndpoints[index])")
            }
            return payload
        
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
                        let signalParse = Int(newPhoneModel.signalLength ?? Double(0))
                        var signalLength: Double = 0
                        switch signalParse {
                        case let x where x >= 8:
                            signalLength = 1
                            break
                        case let x where x > 3:
                            signalLength = 0.5
                            break
                        case let x where x <= 3:
                            signalLength = 0.1
                            break
                        default:
                            signalLength = 0
                        }
                        //                    if(phoneStatus?.signalLength != nil){
                        //                        if (phoneStatus!.signalLength! < 4){
                        //                            signalLength = 0.1
                        //                        }else if(phoneStatus!.signalLength! < 8){
                        //                            signalLength = 0.5
                        //                        }else {
                        //                            signalLength = 1
                        //                        }
                        //                    }
                        let copyData = phoneStatus!.copyWith(
                            battery_level: newPhoneModel.battery_level,
                            isCharging: newPhoneModel.isCharging,
                            signalLength: newPhoneModel.signalLength
                        )
                        
                        phoneStatus = copyData.copyWith(signalLength: signalLength)
                        
                    }else if(kind == "initial"){
                        
                        
                        
                        guard var phoneModel = try? decoder.decode(PhoneStatus.self, from: data) else{return}
                        let batteryLevelParse = Int(phoneModel.battery_level ?? "0") ?? 0
                        var batteryIcon = ""
                        switch batteryLevelParse {
                        case let x where x > 80 :
                            
                            batteryIcon = "battery.\(100)percent"
                            break
                        case let x where x >= 60 && x <= 80:
                            
                            batteryIcon = "battery.\(75)percent"
                            break
                        case let x where x < 60 && x > 30:
                            
                            batteryIcon = "battery.\(50)percent"
                            break
                        case let x where x <= 30:
                            
                            batteryIcon = "battery.\(25)percent"
                            break
                        default:
                            break
                        }
                        
                        
                        
                        phoneModel.batteryIcon = batteryIcon
                        phoneModel.endpointID = endpointID
                        phoneStatus = phoneModel
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
            
        }
    
    func connectionManager(
        _ connectionManager: ConnectionManager, didReceive stream: InputStream,
        withID payloadID: PayloadID, from endpointID: EndpointID,
        cancellationToken token: CancellationToken) {
            // We have received a readable stream.
            print("Receiving a readable Stream")
        }
    
    func connectionManager(
        _ connectionManager: ConnectionManager,
        didStartReceivingResourceWithID payloadID: PayloadID,
        from endpointID: EndpointID, at localURL: URL,
        withName name: String, cancellationToken token: CancellationToken) {
            // We have started receiving a file. We will receive a separate transfer update
            // event when complete.
            // Mendapatkan URL ke direktori dokumen pengguna
            let fileManager = FileManager.default
            guard let documentDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                fatalError("Unable to access the document directory.")
            }
            //
            //        // Menentukan URL tujuan di direktori dokumen pengguna
            let destinationURL = documentDirectory.appendingPathComponent(randomString(length: 10, pathExtension: localURL.pathExtension))
            
            do {
                // Menyalin file dari sumber ke tujuan
                try fileManager.moveItem(at: localURL, to: destinationURL)
                print("File copied successfully to \(destinationURL)")
            } catch {
                print("Failed to copy file: \(error)")
            }
            
            print("Receiving a file as Stream")
            print("Payload ID : \(payloadID)")
            print("Endpoint ID : \(endpointID)")
            print("LocalURL : \(localURL)")
            print("name : \(name)")
        }
    
    func connectionManager(
        _ connectionManager: ConnectionManager,
        didReceiveTransferUpdate update: TransferUpdate,
        from endpointID: EndpointID, forPayload payloadID: PayloadID) {
            // A success, failure, cancelation or progress update.
            print("Receiver Transfer Update Status :  \(update)")
            guard let connectionIndex = connectedEndpoints.firstIndex(where: { $0.endpointID == endpointID }),
                  let payloadIndex = connectedEndpoints[connectionIndex].payload.firstIndex(where: { $0.id == payloadID }) else {
                return
            }
            switch update {
            case .success:
                connectedEndpoints[connectionIndex].payload[payloadIndex].status = .success
            case .canceled:
                connectedEndpoints[connectionIndex].payload[payloadIndex].status = .canceled
            case .failure:
                connectedEndpoints[connectionIndex].payload[payloadIndex].status = .failure
            case let .progress(progress):
                connectedEndpoints[connectionIndex].payload[payloadIndex].status = .inProgress(progress)
            }
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
