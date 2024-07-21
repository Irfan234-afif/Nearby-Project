//
//  AppDelegate.swift
//  NearShare
//
//  Created by irfan  Afifi on 16/02/24.
//

import Cocoa
import SwiftUI

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem:NSStatusItem?
    @ObservedObject var manager : ServiceManager = ServiceManager()
    @State var isDiscover : Bool = false;
    @State var isAdvertiser : Bool = false;
    let menu=NSMenu()
    let itemDiscover = NSMenuItem()
    let width = 220

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let containerDis = NSView(frame: NSRect(x: 0, y: 0, width: 220, height: 30))

                // Teks Label
        let labelDis = NSTextField(labelWithString: "Discovery")
        labelDis.frame = NSRect(x: 12, y: 0, width: 150, height: 20)
        containerDis.addSubview(labelDis)

                // NSSwitch
        let switchButtonDis = NSSwitch(frame: NSRect(x: 160, y: 0, width: 50, height: 20))
        switchButtonDis.target = self
        switchButtonDis.action = #selector(switchMenuItemClicked(_:))
        containerDis.addSubview(switchButtonDis)
    
        let menuItemDis = NSMenuItem()
        menuItemDis.view = containerDis
        menu.addItem(menuItemDis)
        let containerAdv = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))

                // Teks Label
        let labelAdv = NSTextField(labelWithString: "Advertising")
        labelAdv.frame = NSRect(x: 12, y: 5, width: 150, height: 20)
        containerAdv.addSubview(labelAdv)

                // NSSwitch
        let switchButtonAdv = NSSwitch(frame: NSRect(x: 160, y: 0, width: 50, height: 20))
        switchButtonAdv.target = self
        switchButtonAdv.action = #selector(advertisingSwitch(_:))
        containerAdv.addSubview(switchButtonAdv)
    
        let menuItemAdv = NSMenuItem()
        menuItemAdv.view = containerAdv
        menu.addItem(menuItemAdv)
        menu.addItem(NSMenuItem.separator())
        statusItem=NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let image = NSImage(contentsOfFile: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AirDrop.icns")!
        image.size = NSSize(width: 18, height: 18)
        
        manager.discoverDevices.forEach({item in
            menu.addItem(withTitle: item.name, action: nil, keyEquivalent: "")
            
        })
        
        statusItem?.button?.image = image
        statusItem?.menu=menu
        statusItem?.behavior = .removalAllowed
        statusItem?.isVisible = true
        
    }
    
    @objc func switchMenuItemClicked(_ sender: NSSwitch) {
        // Aksi yang akan dijalankan ketika switch diubah
        // Tambahkan logika Anda di sini untuk menangani perubahan switch
        let value = sender.state == .on ? true : false
        if(value){
            manager.startDiscover()
            itemDiscover.view = DiscoverView(frame: NSRect(x: 0, y: 0, width: width, height: 100))
            menu.addItem(itemDiscover)
        }else{
            menu.removeItem(itemDiscover)
        }
        print("Switch state changed to: \(sender.state.rawValue)")
//        menu.addItem(withTitle: "Klik", action: nil, keyEquivalent: "")
        
    }
    @objc func advertisingSwitch(_ sender: NSSwitch) {
        // Aksi yang akan dijalankan ketika switch diubah
        // Tambahkan logika Anda di sini untuk menangani perubahan switch
        let value = sender.state == .on ? true : false
        if(value){
            manager.startAdvertiser()
//            itemDiscover.view = DiscoverView(frame: NSRect(x: 0, y: 0, width: width, height: 100))
//            menu.addItem(itemDiscover)
        }else{
//            menu.removeItem(itemDiscover)
        }
        print("Switch state changed to: \(sender.state.rawValue)")
//        menu.addItem(withTitle: "Klik", action: nil, keyEquivalent: "")
        
    }
    @objc func toggleMenuItemClicked(_ sender: NSMenuItem) {
            // Aksi yang akan dijalankan ketika toggle diubah
            sender.state = sender.state == .on ? .off : .on
            // Tambahkan logika Anda di sini untuk menangani perubahan toggle
        }
    
    func viewOnDiscover(){
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusItem?.isVisible = true
        return true
    }


}

