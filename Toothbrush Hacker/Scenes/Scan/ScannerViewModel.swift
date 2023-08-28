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
    
    @Published var scanningState: BleScanningState = .idle
    @Published var devices: [ScannedDevice] = []
    
    let bleScanner: BleScanner
    let bleConnector: BleConnector

    var subs: Set<AnyCancellable> = []
    
    init(bleScanner: BleScanner, bleConnector: BleConnector) {
        self.bleScanner = bleScanner
        self.bleConnector = bleConnector

        bleScanner.scaninngStatePublisher
            .sink { self.scanningState = $0 }
            .store(in: &subs)
        
        bleScanner.discoveredPeripheralsPublisher
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
        bleScanner.startScan()
    }
    
    private func stopScan() {
        bleScanner.stopScan()
    }
    
    func connect(device: ScannedDevice) {
        bleConnector.connectDevice(withId: device.id)
    }
}
