//
//  ScannerViewModel.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/26/23.
//

import Foundation
import Combine
import CoreBluetooth

@MainActor
class ScannerViewModel: ObservableObject {
    
    @Published var scanningState: ScanningState = .idle
    @Published var connectedState: ConnectedState = .disconnected
    @Published var devices: [DiscoveredPeripheral] = []
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let scanner: BleScanner

    var subs: Set<AnyCancellable> = []
    
    init(scanner: BleScanner) {
        self.scanner = scanner

        scanner.scaninngStatePublisher
            .receive(on: RunLoop.main)
            .sink { self.scanningState = $0 }
            .store(in: &subs)
        
        scanner.discoveredPeripheralPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .compactMap { $0 }
            .filter { !self.devices.contains($0) }
            .sink { self.devices.append($0) }
            .store(in: &subs)
    }
    
    func toggleScan() {
        if scanningState == .idle {
            startScan()
        } else {
            stopScan()
        }
    }
    
    private func startScan() {
        do {
            try scanner.startScan()
        } catch {
            show(alertMessage: "Could not start the scan. Is Bluetooth turned on and are app pemissions granted?")
        }
    }
    
    private func stopScan() {
        scanner.stopScan()
    }
    
    func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
}
