//
//  PopupWindowController.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 22/07/24.
//

import Cocoa
import SwiftUI

class PopupWindowController: NSWindowController {
//    private var manager:ServiceManager;
    init(rootView: NSView) {
//        manager = serviceManager
//        initWindow()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 10),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Send File"
        window.isReleasedWhenClosed = false
//        self.window = window
        
//        let contentView = NSHostingView(rootView: PopupContentView().environmentObject(manager))
        window.contentView = rootView
        window.contentView?.superview?.frame.size = rootView.fittingSize
        window.center()
        
        let contentSize = rootView.fittingSize
                window.setContentSize(contentSize)
        
        super.init(window: window)
    }
    func initWindow() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
        window?.orderFront(nil)
        window?.level = .floating  // Ensure the window stays on top
    }
}
