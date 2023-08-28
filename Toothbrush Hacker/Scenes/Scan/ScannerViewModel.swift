//
//  ScannerViewModel.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/26/23.
//

import Foundation
import Combine

@MainActor
class ScannerViewModel: ObservableObject {
    
    @Published var scanningState: ScanningState = .idle
    @Published var devices: [ScannedDevice] = []
    
    let scanner: DeviceScanner
    let connector: DeviceConnector

    var subs: Set<AnyCancellable> = []
    
    init(scanner: DeviceScanner, connector: DeviceConnector) {
        self.scanner = scanner
        self.connector = connector

        scanner.scaninngStatePublisher
            .sink { self.scanningState = $0 }
            .store(in: &subs)
        
        scanner.discoveredPeripheralsPublisher
            .sink {
                self.devices = $0.map {
                    ScannedDevice(
                        id: $0.identifier,
                        name: $0.name ?? "<<Unnamed device>>"
                    )
                }
            }
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
        scanner.startScan()
    }
    
    private func stopScan() {
        scanner.stopScan()
    }
    
    func connect(device: ScannedDevice) {
        connector.connectDevice(withId: device.id)
    }
}
