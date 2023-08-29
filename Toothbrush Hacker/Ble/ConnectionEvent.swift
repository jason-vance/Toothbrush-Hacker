//
//  ConnectionEvent.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth

enum ConnectionEvent {
    case didFailToConnect(CBPeripheral, Error?)
    case didConnect(CBPeripheral)
    case didDisconnect(CBPeripheral, Error?)
}
