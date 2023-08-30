//
//  ByteArrayExtensions.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation

extension Array<UInt8> {
    func getValue<Value>(_ type: Value.Type, at start: Int, isLittleEndian: Bool = true) -> Value? where Value: FixedWidthInteger {
        let length = type.bitWidth / UInt8.bitWidth
        guard self.count >= start + length else {
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
}
