//
//  BleDescriptor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class BleDescriptor {
    
    var uuid: CBUUID { cbDescriptor.uuid }
    unowned let bleCharacteristic: BleCharacteristicProtocol
    let cbDescriptor: CBDescriptor
    
    @Published var valueBytes: [UInt8]? = nil
    
    init?(cbDescriptor: CBDescriptor, bleCharacteristic: BleCharacteristicProtocol) {
        self.cbDescriptor = cbDescriptor
        self.bleCharacteristic = bleCharacteristic
    }
    
    static func create(with cbDescriptor: CBDescriptor, bleCharacteristic: BleCharacteristicProtocol) -> BleDescriptor? {
        var bleDescriptor =
            CharacteristicFormatDescriptor(cbDescriptor: cbDescriptor, bleCharacteristic: bleCharacteristic) ??
            ClientCharacteristicConfigurationDescriptor(cbDescriptor: cbDescriptor, bleCharacteristic: bleCharacteristic) ??
            nil
            
        if bleDescriptor == nil {
            bleDescriptor = bleCharacteristic.createDescriptor(with: cbDescriptor)
        }
        if bleDescriptor == nil {
            print("Couldn't create BleDescriptor with \(cbDescriptor) for \(bleCharacteristic.uuid)")
        }
        return bleDescriptor
    }
    
    func communicator(_ communicator: BlePeripheralCommunicator, receivedValueUpdateFor cbDescriptor: CBDescriptor) {
        guard let data = cbDescriptor.value as? Data else { return }
        valueBytes = [UInt8](data)
        printValueBytes()
    }
}

extension BleDescriptor: Equatable {
    static func == (lhs: BleDescriptor, rhs: BleDescriptor) -> Bool {
        lhs.uuid == rhs.uuid
    }
}

extension BleDescriptor: Hashable {
    var hashValue: Int { uuid.hashValue }
    
    func hash(into hasher: inout Hasher) {
        uuid.hash(into: &hasher)
    }
}

extension BleDescriptor {
    func printValueBytes() {
        guard let valueBytes = valueBytes else { return }
        print("BleDescriptor(\(uuid)).valueBytes: \(valueBytes.toString())")
    }
}
