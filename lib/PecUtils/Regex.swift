//
//  Regex.swift
//  PecUtils
//
//  Created by Julian Gernun on 3/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

public class Regex {
    private var regex: NSRegularExpression?
    
    public init(_ pattern: String) {
        do {
            try regex = NSRegularExpression(pattern: pattern,
                options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            
        }
    }
    
    public func match(input: String) -> Bool {
        if let matches = regex?.matchesInString(input,
            options: NSMatchingOptions(),
            range: NSRange(location: 0, length: input.characters.count)) {
                return matches.count > 0
        } else {
            return false
        }
    }
}