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

class FloatWindow: NSWindow {

    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    var floatDelegate: FloatDelegate?
    
    init(contentRect: NSRect, styleMask style: NSWindow.StyleMask = .borderless, backing bufferingType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, image: CGImage) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        isMovableByWindowBackground = true
        hasShadow = true
        contentView?.wantsLayer = true
        contentView?.layer?.contents = image
        
        fade(isIn: true, completion: nil)
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)

        let combo = KeyCombo(keyCode: Int(event.keyCode), cocoaModifiers: event.modifierFlags)
        if event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue != 0 {
            guard let char = combo?.characters.first else { return }
            switch char {
            case "S":
                let saveLabel = NSTextField(frame: NSRect(x: 10, y: 10, width: 80, height: 26))
                saveLabel.stringValue = "Save"
                saveLabel.textColor = .white
                saveLabel.font = NSFont.boldSystemFont(ofSize: 20)
                saveLabel.alignment = .center
                saveLabel.drawsBackground = true
                saveLabel.backgroundColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
                saveLabel.wantsLayer = true
                saveLabel.layer?.cornerRadius = 10.0
                saveLabel.isBordered = false
                saveLabel.isEditable = false
                saveLabel.isSelectable = false
                contentView?.addSubview(saveLabel)
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if let image = self.contentView?.layer?.contents {
                        saveLabel.removeFromSuperview()
                        self.floatDelegate?.save(floatWindow: self, image: image as! CGImage)
                    }
                }
            case "W":
                fade(isIn: false) {
                    self.floatDelegate?.close(floatWindow: self)
                }
            case "C":
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if let image = self.contentView?.layer?.contents {
                        let cgImage = image as! CGImage
                        let size = CGSize(width: cgImage.width, height: cgImage.height)
                        let nsImage = NSImage(cgImage: cgImage, size: size)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.writeObjects([nsImage])
                    }
                }
            default:
                break
            }
        } else if event.keyCode == UInt16(kVK_Escape) {
            fade(isIn: false) {
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
    
    private func fade(isIn: Bool, completion: (() -> Void)?) {
        alphaValue = isIn ? 0.0 : 1.0
        makeKeyAndOrderFront(self)
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = completion
        NSAnimationContext.current.duration = 0.2
        animator().alphaValue = isIn ? 1.0 : 0.0
        NSAnimationContext.endGrouping()
    }
}

protocol FloatDelegate {
    func save(floatWindow: FloatWindow, image: CGImage)
    func close(floatWindow: FloatWindow)
}
