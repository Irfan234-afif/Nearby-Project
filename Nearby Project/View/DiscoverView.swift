//
//  DiscoverView.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 18/02/24.
//

import Foundation
import Cocoa
import SwiftUI

class DiscoverView: NSView {
    
        
    override init(frame frameRect: NSRect) {
        @ObservedObject var manager: ServiceManager = ServiceManager()
        super.init(frame: frameRect)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
            
        }
        
        private func setupView() {
            let stackView = NSStackView(views: [
                        NSTextField(labelWithString: "Item 1"),
                        NSTextField(labelWithString: "Item 2"),
                        NSButton(title: "Button", target: nil, action: nil)
                    ])
                    stackView.orientation = .vertical
                    stackView.spacing = 4
                    stackView.translatesAutoresizingMaskIntoConstraints = false
            
                    
            let scrollView = NSScrollView()
            scrollView.drawsBackground = false
            scrollView.hasVerticalRuler = true
            scrollView.documentView = stackView
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(scrollView)
            
                    
                    NSLayoutConstraint.activate([
                        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
                        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
                        scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
                        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
                    ])
        }
    
    
    @objc private func switchValueChanged(_ sender: NSSwitch) {
            // Handle switch value change
            let value = sender.state == .on ? true : false
            print("Switch value changed: \(value)")
            
            // Update constraints to change size
            layoutSubtreeIfNeeded()
        }
}
