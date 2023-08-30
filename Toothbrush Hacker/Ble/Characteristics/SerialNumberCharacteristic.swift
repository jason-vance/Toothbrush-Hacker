//
//  SerialNumberCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth
import Combine

class SerialNumberCharacteristic: BleCharacteristic {
    
    static let uuid = CBUUID(string: "2A25")
    
    @Published var serialNumber: String? = nil
    
    private var subs: Set<AnyCancellable> = []
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
        
        $valueBytes
            .compactMap { $0 }
            .sink(receiveValue: received(serialNumberBytes:))
            .store(in: &subs)
    }
    
    private func received(serialNumberBytes: [UInt8]) {
        if let string = String(bytes: serialNumberBytes, encoding: .utf8) {
            serialNumber = string
        }
    }
}
