//
//  ContentView.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 15/02/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager : ServiceManager;
    
    @State var isDiscover : Bool = false;
    @State var isAdvertiser : Bool = false;
    
    @State private var text = "";
    var body: some View {
        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
            Text("Hello, world!")
            Toggle("Discovering", isOn: $isDiscover).toggleStyle(SwitchToggleStyle()).onChange(of: isDiscover){oldValue, newValue in
                if(newValue){
                    manager.startDiscover()
                }else{
                    manager.stopAdvertiser()
                }
                
            }
            Toggle("Advertising", isOn: $isAdvertiser).toggleStyle(SwitchToggleStyle()).onChange(of: isAdvertiser){_, newValue in
                if(newValue){
                    manager.startAdvertiser()
                }else{
                    manager.stopAdvertiser()
                }
                
            }
            
            if !manager.connectedEndpoints.isEmpty{
                ForEach(manager.connectedEndpoints){item in
                    HStack{
                        VStack{
                            Text(item.name)
                            Text("Connected")
                        }
                        Spacer()
                        Button{
                            manager.sendText(to: [item.endpointID], value: "Halo tes dari MacOs")
                        }label:{
                            Text("Send")
                        }
                    }
                }
            }
            
            if !manager.conRequests.isEmpty{
                
                ForEach(manager.conRequests){item in
                    HStack{
                        Text(item.endpointName)
                        Spacer()
                        Button{
                            item.shouldAccept(true)
                        }label:{
                            Text("Accpet")
                        }
                        Button{
                            item.shouldAccept(false)
                        }label:{
                            Text("Decline")
                        }
                        
                    }
                }
                
            }
            
//            manager.$discoverDevices.map(<#T##transform: ([DiscoverDevice]) -> T##([DiscoverDevice]) -> T#>)
            if !manager.discoverDevices.isEmpty{
                
            
            ForEach(manager.discoverDevices){item in
                HStack{
                    Text(item.name)
                    Spacer()
                    Button{
                        manager.requestConnect(device: item)
                    }label:{
                        Text("Connect")
                    }
                    
                }
                Divider()
                
            }
            }
//            ForEach(manager.discoverDevices, id: \.self){item in
//                Text("Halo")
//                
//            }
//            List{
//                
//            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

