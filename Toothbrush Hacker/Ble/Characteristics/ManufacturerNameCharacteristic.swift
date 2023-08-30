//
//  ManufacturerNameCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth
import Combine

class ManufacturerNameCharacteristic: BleCharacteristic {
    
    static let uuid = CBUUID(string: "2A29")
    
    @Published var manufacturerName: String? = nil
    
    private var subs: Set<AnyCancellable> = []
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
        
        $valueBytes
            .compactMap { $0 }
            .sink(receiveValue: received(manufacturerNameBytes:))
            .store(in: &subs)
    }
    
    private func received(manufacturerNameBytes: [UInt8]) {
        if let string = String(bytes: manufacturerNameBytes, encoding: .utf8) {
            manufacturerName = string
        }
    }
}
