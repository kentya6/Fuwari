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
    
    init(contentRect: NSRect, styleMask style: NSWindow.StyleMask = [.borderless, .resizable], backing bufferingType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, image: CGImage) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        contentView = FloatView(frame: contentRect)
        originalRect = contentRect
        level = .floating
        isMovableByWindowBackground = true
        hasShadow = true
        contentView?.wantsLayer = true
        contentView?.layer?.contents = image
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        self.minSize = NSMakeSize(minWindowScale, minWindowScale)
        
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
        
        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: LocalizedString.Save.value, action: #selector(saveImage), keyEquivalent: "s"))
        menu?.addItem(NSMenuItem(title: LocalizedString.Copy.value, action: #selector(copyImage), keyEquivalent: "c"))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: LocalizedString.ZoomIn.value, action: #selector(zoomInWindow), keyEquivalent: "+"))
        menu?.addItem(NSMenuItem(title: LocalizedString.ZoomOut.value, action: #selector(zoomOutWindow), keyEquivalent: "-"))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: LocalizedString.Close.value, action: #selector(closeWindow), keyEquivalent: "w"))
        
        fadeWindow(isIn: true)
    }
    
    func windowDidResize(_ notification: Notification) {
        let resize = self.frame.size
        windowScale = resize.width > resize.height ? resize.height / originalRect.height : resize.width / originalRect.width
        showPopUp(text: "\(Int(windowScale * 100))%")
    }
    
    override func keyDown(with event: NSEvent) {
        let combo = KeyCombo(keyCode: Int(event.keyCode), cocoaModifiers: event.modifierFlags)
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue != 0 {
            guard let char = combo?.characters.first else { return }
            switch char {
            case "S": // ⌘S
                saveImage()
            case "C": // ⌘C
                copyImage()
            case "=", "^": // ⌘+
                zoomInWindow()
            case "-": // ⌘-
                zoomOutWindow()
            case "W": // ⌘W
                closeWindow()
            default:
                break
            }
        } else if event.keyCode == UInt16(kVK_Escape) {
            closeWindow()
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        if let menu = menu, let contentView = contentView {
            NSMenu.popUpContextMenu(menu, with: event, for: contentView)
        }
    }
    
    @objc private func saveImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let image = self.contentView?.layer?.contents {
                self.showPopUp(text: "Save")
                self.floatDelegate?.save(floatWindow: self, image: image as! CGImage)
            }
        }
    }
    
    @objc private func copyImage() {
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
    }
    
    @objc private func zoomInWindow() {
        if windowScale < maxWindowScale {
            windowScale += windowScaleInterval
            setFrame(NSRect(x: frame.origin.x - (originalRect.width / 2 * windowScaleInterval), y: frame.origin.y - (originalRect.height / 2 * windowScaleInterval), width: originalRect.width * windowScale, height: originalRect.height * windowScale), display: true)
        }
        
        showPopUp(text: "\(Int(windowScale * 100))%")
    }
    
    @objc private func zoomOutWindow() {
        if windowScale > minWindowScale {
            windowScale -= windowScaleInterval
            setFrame(NSRect(x: frame.origin.x + (originalRect.width / 2 * windowScaleInterval), y: frame.origin.y + (originalRect.height / 2 * windowScaleInterval), width: originalRect.width * windowScale, height: originalRect.height * windowScale), display: true)
        }
        
        showPopUp(text: "\(Int(windowScale * 100))%")
    }
    
    @objc private func closeWindow() {
        floatDelegate?.close(floatWindow: self)
    }
    
    private func showPopUp(text: String, duration: Double = 1.0) {
        popUpLabel.stringValue = text
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            popUpLabel.animator().alphaValue = 1.0
        }) {
            if #available(OSX 10.12, *) {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = duration
                    context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                    self.popUpLabel.animator().alphaValue = 0.0
                })
            }
        }
    }
    
    func fadeWindow(isIn: Bool, completion: (() -> Void)? = nil) {
        makeKeyAndOrderFront(self)
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = completion
        NSAnimationContext.current.duration = 0.2
        animator().alphaValue = isIn ? 1.0 : 0.0
        NSAnimationContext.endGrouping()
    }
}
