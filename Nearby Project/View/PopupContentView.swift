//
//  PopupContentView.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 22/07/24.
//
import SwiftUI

struct PopupContentView: View {
    @State var isChoosingFile = false
    @EnvironmentObject var manager:ServiceManager;
    @State var urlSelected: URL? = nil
    @State var sendedPayload : Payload? = nil
    @State var isSuccess = false
    
    var body: some View {
        VStack {
            Text("Choose File to send")
                .font(.headline)
                .padding()
            Text("Make sure the file is in the download folder").foregroundColor(.green).fontWeight(.bold).padding()
            
            
            if urlSelected != nil{
                Text("Device for send \(manager.connectedEndpoints.first?.name ?? "-")")
                Text("File : \(urlSelected!.lastPathComponent)")
            }
            
            if sendedPayload != nil && sendedPayload?.progressValue != nil{
                if(isSuccess){
                    ProgressView(value: 1.00, total: 1.000)
                    Text("File berhasil di kirim").padding().foregroundColor(.green).fontWeight(.bold)
                }else{
                if let payloadIndex = manager.connectedEndpoints.first?.payload.firstIndex(where: { $0.id == sendedPayload?.id }) {
                    let payload = manager.connectedEndpoints.first?.payload[payloadIndex]
                    switch payload?.status {
                    case .inProgress(let progress):
                        var fractionCompleted = progress.fractionCompleted
                        ProgressView(value: fractionCompleted, total: 1.000)
                    case.success:
                        ProgressView(value: 1.00, total: 1.000)
                        Text("File berhasil di kirim").padding().foregroundColor(.green).fontWeight(.bold)
                    default:
                        EmptyView()
                    }
                }
                }
//                ProgressView(value: sendedPayload!.progressValue)
//                ProgressView(value: sendedPayload!.progressValue, total: 1 )
            }
            
            HStack{
                Button("Choose File") {
                    isChoosingFile = true
                }
                if urlSelected != nil{
                    Button("Send File Now"){
                        if manager.connectedEndpoints.first != nil{
                            sendedPayload =  manager.sendFile(to:[manager.connectedEndpoints.first?.endpointID ?? ""],url: urlSelected!)
                        }
                    }
                }
            }
            
            
        }.padding().fileImporter(isPresented: $isChoosingFile, allowedContentTypes: [.item], onCompletion: {result in
            switch result {
            case .success(let url):
                sendedPayload = nil
                urlSelected = nil
                isSuccess = false
                urlSelected = url
                //                if manager.connectedEndpoints.first != nil{
                //                    manager.sendFile(to:[manager.connectedEndpoints.first?.endpointID ?? ""],url: url)
                //                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
