//
//  FloatWindow.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/07.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Magnet
import Carbon

protocol FloatDelegate {
    func save(floatWindow: FloatWindow, image: CGImage)
    func close(floatWindow: FloatWindow)
}

class FloatWindow: NSWindow {

    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    var floatDelegate: FloatDelegate?
    
    private var originalRect = NSRect()
    private var popUpLabel = NSTextField()
    private var windowScale = CGFloat(1.0)
    private let windowScaleInterval = CGFloat(0.25)
    private let minWindowScale = CGFloat(0.25)
    private let maxWindowScale = CGFloat(2.5)
    
    init(contentRect: NSRect, styleMask style: NSWindow.StyleMask = .borderless, backing bufferingType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, image: CGImage) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        
        originalRect = contentRect
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        isMovableByWindowBackground = true
        hasShadow = true
        contentView?.wantsLayer = true
        contentView?.layer?.contents = image
        
        popUpLabel = NSTextField(frame: NSRect(x: 10, y: 10, width: 80, height: 26))
        popUpLabel.textColor = .white
        popUpLabel.font = NSFont.boldSystemFont(ofSize: 20)
        popUpLabel.alignment = .center
        popUpLabel.drawsBackground = true
        popUpLabel.backgroundColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        popUpLabel.wantsLayer = true
        popUpLabel.layer?.cornerRadius = 10.0
        popUpLabel.isBordered = false
        popUpLabel.isEditable = false
        popUpLabel.isSelectable = false
        popUpLabel.alphaValue = 0.0
        contentView?.addSubview(popUpLabel)
        
        fadeWindow(isIn: true)
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)

        let combo = KeyCombo(keyCode: Int(event.keyCode), cocoaModifiers: event.modifierFlags)
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue != 0 {
            guard let char = combo?.characters.first else { return }
            switch char {
            case "S": // ⌘S
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if let image = self.contentView?.layer?.contents {
                        self.showPopUp(text: "Save")
                        self.floatDelegate?.save(floatWindow: self, image: image as! CGImage)
                    }
                }
            case "W": // ⌘W
                fadeWindow(isIn: false) {
                    self.floatDelegate?.close(floatWindow: self)
                }
            case "C": // ⌘C
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if let image = self.contentView?.layer?.contents {
                        let cgImage = image as! CGImage
                        let size = CGSize(width: cgImage.width, height: cgImage.height)
                        let nsImage = NSImage(cgImage: cgImage, size: size)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.writeObjects([nsImage])
                        self.showPopUp(text: "Copy")
                    }
                }
            case "=": // ⌘+
                if windowScale < maxWindowScale {
                    windowScale += windowScaleInterval
                    setFrame(NSRect(x: frame.origin.x - (originalRect.width / 2 * windowScaleInterval), y: frame.origin.y - (originalRect.height / 2 * windowScaleInterval), width: originalRect.width * windowScale, height: originalRect.height * windowScale), display: true)
                }
                showPopUp(text: "\(Int(windowScale * 100))%")
            case "-": // ⌘-
                if windowScale > minWindowScale {
                    windowScale -= windowScaleInterval
                    setFrame(NSRect(x: frame.origin.x + (originalRect.width / 2 * windowScaleInterval), y: frame.origin.y + (originalRect.height / 2 * windowScaleInterval), width: originalRect.width * windowScale, height: originalRect.height * windowScale), display: true)
                }
                showPopUp(text: "\(Int(windowScale * 100))%")
            default:
                break
            }
        } else if event.keyCode == UInt16(kVK_Escape) {
            fadeWindow(isIn: false) {
                self.floatDelegate?.close(floatWindow: self)
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        alphaValue = 0.4
    }
    
    override func mouseUp(with event: NSEvent) {
        alphaValue = 1.0
    }
    
    private func showPopUp(text: String, duration: Double = 0.3) {
        popUpLabel.stringValue = text
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            popUpLabel.animator().alphaValue = 1.0
        }) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                self.popUpLabel.animator().alphaValue = 0.0
            })
        }
    }
    
    private func fadeWindow(isIn: Bool, completion: (() -> Void)? = nil) {
        makeKeyAndOrderFront(self)
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = completion
        NSAnimationContext.current.duration = 0.2
        animator().alphaValue = isIn ? 1.0 : 0.0
        NSAnimationContext.endGrouping()
    }
}
