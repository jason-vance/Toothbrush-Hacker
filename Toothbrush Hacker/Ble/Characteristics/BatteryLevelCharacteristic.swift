//
//  BatteryLevelCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth
import Combine

class BatteryLevelCharacteristic: BleCharacteristic {
    
    static let uuid = CBUUID(string: "2A19")
    
    @Published var batteryLevel: Double? = nil
    
    private var subs: Set<AnyCancellable> = []
    
    init() {
        super.init(uuid: Self.uuid)
        
        $valueBytes
            .compactMap { $0 }
            .sink(receiveValue: batteryLevelReceived(_:))
            .store(in: &subs)
    }
    
    private func batteryLevelReceived(_ batteryLevelBytes: [UInt8]) {
        if let batteryLevelInt = batteryLevelBytes.getValue(UInt8.self, at: 0) {
            batteryLevel = Double(batteryLevelInt) / 100.0
            print("BatteryLevelCharacteristic.batteyLevelReceived batteryLevel: \(batteryLevel!)")
        }
    }
}
