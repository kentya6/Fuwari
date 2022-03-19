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

    private var eventHandler: ((URL, NSRect?) -> Void)?

    func eventHandler(eventHandler: @escaping (URL, NSRect?) -> Void) {
        self.eventHandler = eventHandler
    }

    func startCapture() {
        let fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent("fuwari-temporary-screenshot.png")
        let captureProcess = Process()
        let pipe = Pipe()
        captureProcess.launchPath = "/usr/sbin/screencapture"
        captureProcess.arguments = ["-x", "-i", "-o"] + [fileUrl.path]
        captureProcess.environment = ["OS_ACTIVITY_DT_MODE": "YES"]
        captureProcess.standardError = pipe
        captureProcess.terminationHandler = { task in
            guard task.terminationStatus == 0 else { return }
            let output = pipe.fileHandleForReading.availableData
            let str = String(decoding: output, as: UTF8.self)
            let rect = self.extractCoordinates(str: str)
            DispatchQueue.main.async { [weak self] in
                self?.eventHandler?(fileUrl, rect)
            }
        }
        captureProcess.launch()
    }

    func extractCoordinates(str: String) -> NSRect? {
        // Note, not found when capturing a window, rather than a selection
        let capturePattern = #"captureRect = \((?<x>[\d.]+), (?<y>[\d.]+), (?<width>[\d.]+), (?<height>[\d.]+)\)"#

        guard let match = Regex.match(str: str, regexPattern: capturePattern) else {
            return nil
        }

        let getIntFromRegexGroup = {(name: String) throws -> Int in
            Int(round(Float(try Regex.getGroup(match: match, name: name, str: str))!))
        }

        do {
            return try NSRect(
                x: getIntFromRegexGroup("x"),
                y: getIntFromRegexGroup("y"),
                width: getIntFromRegexGroup("width"),
                height: getIntFromRegexGroup("height")
            )
        } catch RegexError.missingGroup(let name) {
            print("missing group: \(name)")
            return nil
        } catch {
            return nil
        }
    }
}
