//
//  BleDescriptor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class BleDescriptor {
    
    let uuid: CBUUID
    let descriptor: CBDescriptor
    
    init(uuid: CBUUID, descriptor: CBDescriptor) {
        self.uuid = uuid
        self.descriptor = descriptor
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
