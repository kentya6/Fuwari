//
//  ScreenshotManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2018/07/01.
//  Copyright © 2018年 AppKnop. All rights reserved.
//

import Cocoa

class ScreenshotManager: NSObject {
    private var eventHandler: (URL) -> Void
    private var eventStream: FSEventStreamRef?
    
    static let shared = ScreenshotManager(eventHandler: {_ in })
    
    init(eventHandler: @escaping (URL) -> Void) {
        self.eventHandler = eventHandler
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        guard let path = screenshotDirectoryURL?.path else {
            print("Failed to get screenshot directory")
            return
        }
        
        let streamCallback: FSEventStreamCallback = {
            (streamRef: ConstFSEventStreamRef,
            clientCallBackInfo: UnsafeMutableRawPointer?,
            numEvents: Int,
            eventPaths: UnsafeMutableRawPointer,
            eventFlags: UnsafePointer<FSEventStreamEventFlags>,
            eventIds: UnsafePointer<FSEventStreamEventId>) in
            
            guard let eventPaths = Unmanaged<NSArray>
                .fromOpaque(eventPaths)
                .takeUnretainedValue() as? [String] else {
                    NSLog("Failed to get eventPaths")
                    return
            }
            
            guard let clientCallBackInfo = clientCallBackInfo else {
                print("Failed to get clientCallBackInfo")
                return
            }
            
            let screenshotMonitor = Unmanaged<ScreenshotManager>
                .fromOpaque(clientCallBackInfo)
                .takeUnretainedValue()
            
            eventPaths.forEach {
                screenshotMonitor.handleEvent(withURL: URL(fileURLWithPath: $0))
            }
        }
        
        var streamContext = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passRetained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil)
        
        guard let eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            streamCallback,
            &streamContext,
            [path] as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes
                | kFSEventStreamCreateFlagIgnoreSelf
                | kFSEventStreamCreateFlagFileEvents))
            else {
                print("Failed to create eventStream")
                return
        }
        
        self.eventStream = eventStream
        
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(eventStream)
    }
    
    func stopMonitoring() {
        if let screenshotEventStream = eventStream {
            FSEventStreamStop(screenshotEventStream)
            FSEventStreamInvalidate(screenshotEventStream)
            FSEventStreamRelease(screenshotEventStream)
        }
    }
    
    func eventHandler(eventHandler: @escaping (URL) -> Void) {
        self.eventHandler = eventHandler
    }
    
    func handleEvent(withURL url: URL) {
        if recentScreenshotExists(at: url) {
            eventHandler(url)
        }
    }
    
    func recentScreenshotExists(at url: URL) -> Bool {
        if url.lastPathComponent.hasPrefix(".") {
            return false // File is hidden
        }
        
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return false // Failed to get file attributes
        }
        
        let extendedAttributesKey = FileAttributeKey(rawValue: "NSFileExtendedAttributes")
        
        guard let extendedAttributes = attributes[extendedAttributesKey] as? [String: Any] else {
            return false // Failed to get extended attributes
        }
        
        if !extendedAttributes.keys.contains("com.apple.metadata:kMDItemIsScreenCapture") {
            return false // File is not a screenshot
        }
        
        guard let creationDate = attributes[.creationDate] as? Date else {
            return false
        }
        
        if creationDate.timeIntervalSinceNow < -5 {
            return false
        }
        
        return true
    }
    
    var screenshotDirectoryURL: URL? {
        if let domain = UserDefaults.standard.persistentDomain(forName: "com.apple.screencapture"),
            let path = (domain["location"] as? NSString)?.standardizingPath {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue {
                return URL(fileURLWithPath: path)
            }
        }
        
        return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
    }
    
    func startCapture() {
        guard let fileURL = try? FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        let captureProcess = Process()
        captureProcess.launchPath = "/usr/sbin/screencapture"
        captureProcess.arguments = ["-x", "-i"] + [fileURL.appendingPathComponent("fuwari-temporary-screenshot.png").path]
        captureProcess.standardOutput = Pipe()
        captureProcess.terminationHandler = { task in
            guard task.terminationStatus == 0 else {
                return
            }
        }
        captureProcess.launch()
    }
}
