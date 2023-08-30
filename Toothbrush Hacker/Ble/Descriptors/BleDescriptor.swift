//
//  BleDescriptor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class BleDescriptor {
    
    var uuid: CBUUID { descriptor.uuid }
    let descriptor: CBDescriptor
    
    @Published var valueBytes: [UInt8]? = nil
    
    init?(descriptor: CBDescriptor) {
        self.descriptor = descriptor
    }
    
    static func create(with cbDescriptor: CBDescriptor) -> BleDescriptor? {
        let descriptor =
            CharacteristicFormatDescriptor(descriptor: cbDescriptor) ??
            ClientCharacteristicConfigurationDescriptor(descriptor: cbDescriptor) ??
            nil
            
        if descriptor == nil {
            print("Couldn't create BleDescriptor with \(cbDescriptor)")
        }
        return descriptor
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, receivedValueUpdateFor cbDescriptor: CBDescriptor) {
        guard let data = cbDescriptor.value as? Data else { return }
        valueBytes = [UInt8](data)
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
