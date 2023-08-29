//
//  BleDeviceConnection.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth
import Combine

class BleDeviceConnection {
    
    private static var connections: [CBPeripheral:BleDeviceConnection] = [:]
    
    static func getOrCreate(from peripheral: CBPeripheral) -> BleDeviceConnection {
        if !connections.keys.contains(peripheral) {
            let connection = BleDeviceConnection(
                peripheral: peripheral,
                centralManager: .instance
            )
            connections[peripheral] = connection
        }
        
        return connections[peripheral]!
    }
    
    @Published var connectedState: ConnectedState = .disconnected

    let peripheral: CBPeripheral
    let centralManager: BleCentralManager

    private var connectionContinuation: CheckedContinuation<Void,Error>? = nil
    
    private var subs: Set<AnyCancellable> = []

    private init(
        peripheral: CBPeripheral,
        centralManager: BleCentralManager
    ) {
        self.peripheral = peripheral
        self.centralManager = centralManager
    }
    
    private func listenToMyConnectionEvents() {
        centralManager.$connectionEvent
            .compactMap { $0 }
            .filter(isMy(connectionEvent:))
            .sink(receiveValue: onNew(connectionEvent:))
            .store(in: &subs)
    }
    
    private func isMy(connectionEvent: ConnectionEvent) -> Bool {
        switch connectionEvent {
        case .didConnect(let peripheral):
            return peripheral == self.peripheral
        case .didFailToConnect(let peripheral, _):
            return peripheral == self.peripheral
        case .didDisconnect(let peripheral, _):
            return peripheral == self.peripheral
        }
    }
    
    private func onNew(connectionEvent: ConnectionEvent) {
        switch connectionEvent {
        case .didConnect(_):
            connectedState = .connected
            connectionContinuation?.resume()
        case .didFailToConnect(_, let error):
            connectedState = .disconnected
            connectionContinuation?.resume(throwing: error ?? "Unknown error")
        case .didDisconnect(_, let error):
            connectedState = .disconnected
            if error == nil {
                connectionContinuation?.resume()
            }
        }
    }
    
    func connect() async throws {
        defer {
            connectionContinuation = nil
        }
        guard connectedState == .disconnected else {
            throw "I'm not disconnected"
        }
        connectedState = .connecting
        
        print("Connecting to peripheral \(peripheral)")
        listenToMyConnectionEvents()
        try await withCheckedThrowingContinuation { continuation in
            connectionContinuation = continuation
            centralManager.connect(peripheral: peripheral)
        }
    }
    
    func cancelConnection() async throws {
        try await cleanup()
    }
    
    private func cleanup() async throws {
        defer {
            connectionContinuation = nil
        }
        guard peripheral.state == .connected else {
            throw "I'm not connected"
        }
        connectedState = .disconnecting
        
        // Turn off any notifications
        for service in (peripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        try await withCheckedThrowingContinuation { continuation in
            connectionContinuation = continuation
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}
