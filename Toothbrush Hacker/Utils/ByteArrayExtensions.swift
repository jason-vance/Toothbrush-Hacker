//
//  ByteArrayExtensions.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation

extension Array<UInt8> {
    
    static func from<Value>(_ value: Value) -> [UInt8] where Value: FixedWidthInteger {
        let length = value.bitWidth / UInt8.bitWidth

        var array: [UInt8] = []
        for index in 0..<length {
            array.insert(UInt8.init(truncatingIfNeeded: (value >> (index * UInt8.bitWidth))), at: 0)
        }
        return array
    }
    
    func getValue<Value>(_ type: Value.Type, at start: Int = 0, lenient: Bool = true) -> Value? where Value: FixedWidthInteger {
        var length = type.bitWidth / UInt8.bitWidth
        if lenient {
            let lengthToEnd = self.count - start
            length = length > lengthToEnd ? lengthToEnd : length
        }
        guard self.count >= start + length else  {
            print("Array<UInt8>.getValue() - range out of bounds. start: \(start), length: \(length)")
            return nil
        }
        
        var index = -1
        var result = Value.zero
        for byte in self.dropFirst(start).prefix(length) {
            index += 1
            let value = Value(byte) << (index * UInt8.bitWidth)
            result = result + value
        }
        return result
    }
    
    func toString(separator: String = "") -> String {
        var s = "0x"
        for byte in self {
            if s.last != "x" {
                s.append(contentsOf: separator)
            }
            s.append(contentsOf: String(format:"%02X", byte))
        }
        return s
    }
}
