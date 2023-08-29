//
//  CharacteristicFormatDescriptor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

class CharacteristicFormatDescriptor: BleDescriptor {
    static let uuid = CBUUID(string: "2904")
    
    override init?(descriptor: CBDescriptor) {
        guard descriptor.uuid == Self.uuid else { return nil }
        super.init(descriptor: descriptor)
    }
}
