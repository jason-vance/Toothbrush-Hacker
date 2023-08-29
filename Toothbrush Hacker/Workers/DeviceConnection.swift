//
//  DeviceConnection.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

enum ConnectedState {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

protocol DeviceConnection {
    
    var connectedStatePublisher: Published<ConnectedState>.Publisher { get }

    func connect() async throws
    func cancelConnection() async throws
}
