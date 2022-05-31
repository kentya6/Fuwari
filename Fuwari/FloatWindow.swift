//
//  FloatWindow.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/07.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Magnet
import Sauce
import Carbon

protocol FloatDelegate: AnyObject {
    func save(floatWindow: FloatWindow, image: CGImage)
    func close(floatWindow: FloatWindow)
}

class FloatWindow: NSWindow {

    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    weak var floatDelegate: FloatDelegate? = nil
    
    private var closeButton: NSButton!
    private var originalRect = NSRect()
    private var popUpLabel = NSTextField()
    private var windowScale = CGFloat(1.0)
    private var windowOpacity = CGFloat(1.0)
    private let defaults = UserDefaults.standard
    private let windowScaleInterval = CGFloat(0.25)
    private let minWindowScale = CGFloat(0.25)
    private let maxWindowScale = CGFloat(2.5)
    private let closeButtonOpacity = CGFloat(0.5)
    private let closeButtonOpacityDuration = TimeInterval(0.3)
    
    init(contentRect: NSRect, styleMask style: NSWindow.StyleMask = [.borderless, .resizable], backing bufferingType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, image: CGImage) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        contentView = FloatView(frame: contentRect)
        originalRect = contentRect
        level = .floating
        isMovableByWindowBackground = true
        hasShadow = true
        contentView?.wantsLayer = true
        contentView?.layer?.contents = image
        minSize = NSMakeSize(30, 30)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        animationBehavior = NSWindow.AnimationBehavior.alertPanel
        
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
        
        let colorAttributeTitle = NSMutableAttributedString(string: "×")
        let range = NSMakeRange(0, colorAttributeTitle.length)
        colorAttributeTitle.addAttribute(.foregroundColor, value: NSColor.white, range: range)
        closeButton = NSButton(frame: NSRect(x: 4, y: frame.height - 20, width: 16, height: 16))
        closeButton.font = NSFont.boldSystemFont(ofSize: 14)
        closeButton.target = self
        closeButton.action = #selector(closeWindow)
        closeButton.attributedTitle = colorAttributeTitle
        closeButton.isBordered = false
        closeButton.alphaValue = 0.0
        contentView?.addSubview(closeButton)
        
        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: LocalizedString.Copy.value, action: #selector(copyImage), keyEquivalent: "c"))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: LocalizedString.Save.value, action: #selector(saveImage), keyEquivalent: "s"))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: LocalizedString.Upload.value, action: #selector(uploadImage), keyEquivalent: ""))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: LocalizedString.ZoomReset.value, action: #selector(resetWindowScale), keyEquivalent: "r"))
        menu?.addItem(NSMenuItem(title: LocalizedString.ZoomIn.value, action: #selector(zoomInWindow), keyEquivalent: "+"))
        menu?.addItem(NSMenuItem(title: LocalizedString.ZoomOut.value, action: #selector(zoomOutWindow), keyEquivalent: "-"))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: LocalizedString.Close.value, action: #selector(closeWindow), keyEquivalent: "w"))
        
        fadeWindow(isIn: true)
    }
    
    func windowDidResize(_ notification: Notification) {
        windowScale = frame.width > frame.height ? frame.height / originalRect.height : frame.width / originalRect.width
        closeButton.frame = NSRect(x: 4, y: frame.height - 20, width: 16, height: 16)
        showPopUp(text: "\(Int(windowScale * 100))%")
    }
    
    override func keyDown(with event: NSEvent) {
        guard let key = Sauce.shared.key(for: Int(event.keyCode)) else { return }
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue != 0 {
            switch key {
            case .s:
                saveImage()
            case .c:
                copyImage()
            case .r:
                resetWindowScale()
            case .equal, .six, .semicolon, .keypadPlus:
                zoomInWindow()
            case .minus, .keypadMinus:
                zoomOutWindow()
            case .w:
                closeWindow()
            default:
                break
            }
        } else if key == Key.escape {
            closeWindow()
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        if let menu = menu, let contentView = contentView {
            NSMenu.popUpContextMenu(menu, with: event, for: contentView)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = self.closeButtonOpacityDuration
            self.closeButton.animator().alphaValue = self.closeButtonOpacity
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = self.closeButtonOpacityDuration
            self.closeButton.animator().alphaValue = 0.0
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        let min = CGFloat(0.1), max = CGFloat(1.0)
        if windowOpacity > min || windowOpacity < max {
            windowOpacity += event.deltaY * 0.005
            if windowOpacity < min { windowOpacity = min }
            else if windowOpacity > max { windowOpacity = max }
            alphaValue = windowOpacity
        }
    }
    
    override func performClose(_ sender: Any?) {
        closeWindow()
    }
  
    override func mouseDown(with event: NSEvent) {
        let movingOpacity = defaults.float(forKey: Constants.UserDefaults.movingOpacity)
        if movingOpacity < 1 {
            alphaValue = CGFloat(movingOpacity)
        }
        closeButton.alphaValue = 0.0
    }
    
    override func mouseUp(with event: NSEvent) {
        alphaValue = windowOpacity
        closeButton.alphaValue = closeButtonOpacity
        // Double click to close
        if event.clickCount >= 2 {
            closeWindow()
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
    
    @objc private func uploadImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let image = self.contentView?.layer?.contents {
                let cgImage = image as! CGImage
                let size = CGSize(width: cgImage.width, height: cgImage.height)
                let nsImage = NSImage(cgImage: cgImage, size: size)
                GyazoManager.shared.uploadImage(image: nsImage)
            }
        }
    }
    
    @objc private func zoomInWindow() {
        if windowScale < maxWindowScale {
            windowScale = floor((windowScale + windowScaleInterval) * 100) / 100
            setFrame(NSRect(x: frame.origin.x - (originalRect.width / 2 * windowScaleInterval), y: frame.origin.y - (originalRect.height / 2 * windowScaleInterval), width: originalRect.width * windowScale, height: originalRect.height * windowScale), display: true, animate: true)
        }
        
        showPopUp(text: "\(Int(windowScale * 100))%")
    }
    
    @objc private func zoomOutWindow() {
        if windowScale > minWindowScale {
            windowScale = floor((windowScale - windowScaleInterval) * 100) / 100
            setFrame(NSRect(x: frame.origin.x + (originalRect.width / 2 * windowScaleInterval), y: frame.origin.y + (originalRect.height / 2 * windowScaleInterval), width: originalRect.width * windowScale, height: originalRect.height * windowScale), display: true, animate: true)
        }
        
        showPopUp(text: "\(Int(windowScale * 100))%")
    }
    
    @objc fileprivate func resetWindowScale() {
        windowScale = CGFloat(1.0)
        setFrame(NSRect(x: frame.origin.x, y: frame.origin.y, width: originalRect.width * windowScale, height: originalRect.height * windowScale), display: true, animate: true)
    }
    
    @objc private func closeWindow() {
        floatDelegate?.close(floatWindow: self)
    }
    
    private func showPopUp(text: String, duration: Double = 0.5, interval: Double = 0.5) {
        popUpLabel.stringValue = text
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            popUpLabel.animator().alphaValue = 1.0
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = duration
                    context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    self.popUpLabel.animator().alphaValue = 0.0
                })
            }
        }
    }
    
    internal override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(resetWindowScale) {
            return windowScale != CGFloat(1.0)
        }
        return true
    }
    
    func fadeWindow(isIn: Bool, completion: (() -> Void)? = nil) {
        makeKeyAndOrderFront(self)
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = completion
        NSAnimationContext.current.duration = 0.2
        animator().alphaValue = isIn ? 1.0 : 0.0
        NSAnimationContext.endGrouping()
        if !isIn { orderOut(self) }
    }
}
