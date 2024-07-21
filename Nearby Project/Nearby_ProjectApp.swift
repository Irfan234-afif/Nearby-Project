//
//  Nearby_ProjectApp.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 15/02/24.
//

import SwiftUI
import MenuBarExtraAccess

@main
struct Nearby_ProjectApp: App {
    //    @NSApplicationDelegateAdaptor(AppDelegate.self)
    //    private var appDelegate
    
    @StateObject private var manager : ServiceManager = ServiceManager()
    
    
    @State var currentNumber: String = "1"
    @State var isDiscover : Bool = false;
    @State var isAdvertiser : Bool = false;
    @State var isMenuPresented: Bool = false
    
    
    
    var body: some Scene {
        Settings(content: {
            EmptyView()
        })
        //        WindowGroup {
        //            ContentView().environmentObject(manager)
        //        }
        MenuBarExtra(content: {
            ContentMenu(currentNumber: $currentNumber, isDiscover: $isDiscover, isAdvertiser: $isAdvertiser).environmentObject(manager).introspectMenuBarExtraWindow { window in // <-- the magic ✨
                window.animationBehavior = .alertPanel
            }
            
        }, label: {
            Image(systemName: "shareplay")
        }).menuBarExtraStyle(WindowMenuBarExtraStyle())
        //
        MenuBarExtra(content: {
            PhoneView().environmentObject(manager).introspectMenuBarExtraWindow{window in
                window.animationBehavior = .alertPanel
            }
        }, label: {
            Image(systemName: "iphone.circle")
        }).menuBarExtraStyle(.window).menuBarExtraAccess(isPresented: $isMenuPresented){statusItem in
            //
            //
            //        }
        }
        
    }
    
    struct PhoneView:View {
        @EnvironmentObject var manager:ServiceManager;
        
        
        var body: some View {
            VStack(content: {
                
                
                if(manager.phoneStatus == nil ){
                    Text("No Device Connect")
                }else{
                    Divider()
                    Image(systemName: "iphone.radiowaves.left.and.right").resizable().frame(width: 200, height: 150, alignment: Alignment.leading)
                    HStack(spacing: 0){
                        
                        
                        Image(systemName: "wifi", variableValue: abs(Double((manager.phoneStatus!.signalLength ?? 0) / 100)))
                        
                        Spacer().frame(width: 16)
                        if(manager.phoneStatus?.isCharging ?? false ){
                            Image(systemName: "bolt.fill").resizable().frame(width: 8, height: 10).foregroundColor(.green)
                            Spacer().frame(width: 2)
                        }
                        
                        Image(systemName: manager.phoneStatus?.batteryIcon ?? "battery.\(0)percent")
                        
                        
                    }.padding(.all, 4)
                    Divider()
                    HStack(spacing: 2){
                        Image(systemName: "circle.fill").foregroundColor(.green)
                        Text("Device Connected : " + (manager.phoneStatus?.endpointName ?? "Unknown"))
                    }
                    
                    
                    
                }
                
            }).padding(.vertical, 30).padding(.horizontal, 8).frame(maxWidth: 300)
        }
        
    }
    
    struct ExampleView:View {
        var isConnected: Bool;
        var endpointName : String
        var batteryLevel: String
        var isCharging : Bool
        let wifiStrength: Int = 75
        var body: some View {
            VStack(content: {
                
                
                if(!isConnected ){
                    Text("No Device Connect")
                }else{
                    Divider()
                    Image(systemName: "iphone.radiowaves.left.and.right").resizable().frame(width: 200, height: 150, alignment: Alignment.leading)
                    HStack(spacing: 0){
                        
                        
                        Image(systemName: "wifi", variableValue: 0.25)
                        
                        Spacer().frame(width: 16)
                        if(isCharging ){
                            Image(systemName: "bolt.fill").resizable().frame(width: 8, height: 10).foregroundColor(.green)
                            Spacer().frame(width: 2)
                        }
                        
                        Image(systemName: "battery.\(75)percent")
                        
                        
                    }.padding(.all, 4)
                    Divider()
                    Text("Device Connected : \(endpointName ?? "Unknown")")
                    
                    
                }
                
            }).padding(.vertical, 30).padding(.horizontal, 8).frame(maxWidth: 300)
        }
        
    }
    
    struct ExampleView_Previews : PreviewProvider{
        
        static var previews: some View{
            ExampleView(isConnected: true, endpointName: "Android", batteryLevel: "75", isCharging: true)
        }
    }
    struct ContentMenu:View{
        @Binding var currentNumber :String
        @Binding var isDiscover : Bool ;
        @Binding var isAdvertiser : Bool ;
        @EnvironmentObject var manager : ServiceManager;
        var body: some View{
            VStack(content: {
                
                Toggle("Discovering", isOn: $isDiscover).toggleStyle(SwitchToggleStyle()).onChange(of: isDiscover){oldValue, newValue in
                    print("Change Discover")
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
                Divider()
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
            }).padding(.all, 16)
        }
    }
}
