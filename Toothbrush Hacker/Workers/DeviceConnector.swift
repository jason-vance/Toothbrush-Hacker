//
//  DeviceConnector.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

enum ConnectedState {
    case disconnected
    case connected
}

protocol DeviceConnector {
    
    var connectedStatePublisher: Published<ConnectedState>.Publisher { get }
    var connectedPeripheralPublisher: Published<CBPeripheral?>.Publisher { get }

    func connectDevice(withId id: UUID)
    func cancelConnection()
}
