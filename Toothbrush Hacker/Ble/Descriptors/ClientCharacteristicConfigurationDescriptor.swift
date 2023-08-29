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
    
    override init?(descriptor: CBDescriptor) {
        guard descriptor.uuid == Self.uuid else { return nil }
        super.init(descriptor: descriptor)
    }
}
