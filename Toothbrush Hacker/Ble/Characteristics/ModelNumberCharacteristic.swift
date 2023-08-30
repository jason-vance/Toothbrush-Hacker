//
//  ModelNumberCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth
import Combine

class ModelNumberCharacteristic: BleCharacteristic {
    
    static let uuid = CBUUID(string: "2A24")
    
    @Published var modelNumber: String? = nil
    
    private var subs: Set<AnyCancellable> = []
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
        
        $valueBytes
            .compactMap { $0 }
            .sink(receiveValue: received(modelNumberBytes:))
            .store(in: &subs)
    }
    
    private func received(modelNumberBytes: [UInt8]) {
        if let string = String(bytes: modelNumberBytes, encoding: .utf8) {
            modelNumber = string
        }
    }
}
