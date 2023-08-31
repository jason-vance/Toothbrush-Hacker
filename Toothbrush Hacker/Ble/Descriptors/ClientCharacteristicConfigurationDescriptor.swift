//
//  ClientCharacteristicConfigurationDescriptor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class ClientCharacteristicConfigurationDescriptor: BleDescriptor {
    
    static let uuid = CBUUID(string: "2902")
    
    override init?(cbDescriptor: CBDescriptor, bleCharacteristic: BleCharacteristicProtocol) {
        guard cbDescriptor.uuid == Self.uuid else { return nil }
        super.init(cbDescriptor: cbDescriptor, bleCharacteristic: bleCharacteristic)
    }
}
