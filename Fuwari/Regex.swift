//
//  Regex.swift
//  Fuwari
//
//  Created by Ben Lu on 01/03/2022.
//  Copyright © 2022 AppKnop. All rights reserved.
//

import Foundation

struct Regex {
    static func match(str: String, regexPattern: String) -> NSTextCheckingResult? {
        let strRange = NSRange(str.startIndex..<str.endIndex, in: str)

        let regex = try! NSRegularExpression(
            pattern: regexPattern,
            options: []
        )
        let matches = regex.matches(
            in: str,
            options: [],
            range: strRange
        )

        return matches.first
    }

    static func getGroup(match: NSTextCheckingResult, name: String, str: String) throws -> String {
        let matchRange = match.range(withName: name)

        // Extract the substring matching the named capture group
        if let substringRange = Range(matchRange, in: str) {
            let capture = String(str[substringRange])
            return capture
        }
        throw RegexError.missingGroup(name: name)
    }
}

enum RegexError: Error {
    case missingGroup(name: String)
}
