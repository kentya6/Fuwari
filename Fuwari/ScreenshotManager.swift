//
//  ScreenshotManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2018/07/01.
//  Copyright © 2018年 AppKnop. All rights reserved.
//

import Cocoa

class ScreenshotManager: NSObject {
    
    static let shared = ScreenshotManager()

    private var eventHandler: ((URL) -> Void)?
    
    func eventHandler(eventHandler: @escaping (URL) -> Void) {
        self.eventHandler = eventHandler
    }
    
    func startCapture() {
        guard let fileUrl = try? FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fuwari-temporary-screenshot.png") else { return }
        let captureProcess = Process()
        captureProcess.launchPath = "/usr/sbin/screencapture"
        captureProcess.arguments = ["-x", "-i"] + [fileUrl.path]
        captureProcess.standardOutput = Pipe()
        captureProcess.terminationHandler = { task in
            guard task.terminationStatus == 0 else { return }
            DispatchQueue.main.async { [weak self] in
                self?.eventHandler?(fileUrl)
            }
        }
        captureProcess.launch()
    }
}
